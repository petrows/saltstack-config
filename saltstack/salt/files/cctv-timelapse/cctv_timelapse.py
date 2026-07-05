#!/usr/bin/env python3
"""CCTV timelapse capture service.

Reads a YAML configuration file with a list of camera streams and
periodically dumps a still image from each camera into a subfolder
named after the camera. Image files are named with a timestamp.

Example configuration:

    output_dir: /srv/cctv-timelapse/data
    interval: 60
    timeout: 15
    retries: 3
    retry_delay: 5
    cameras:
      - name: front-door
        url: rtsp://user:pass@10.0.0.10:554/stream1
      - name: backyard
        url: http://10.0.0.11/snapshot.jpg
"""

from __future__ import annotations

import argparse
import logging
import signal
import subprocess
import sys
import threading
import time
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path
from types import FrameType

import yaml

LOG = logging.getLogger("cctv-timelapse")

DEFAULT_INTERVAL = 60
DEFAULT_TIMEOUT = 15
DEFAULT_RETRIES = 3
DEFAULT_RETRY_DELAY = 5
TIMESTAMP_FORMAT = "%Y%m%d-%H%M%S"


class ConfigError(Exception):
    """Raised when the configuration file is invalid."""


@dataclass(frozen=True)
class Camera:
    """A single camera stream definition."""

    name: str
    url: str


@dataclass(frozen=True)
class Config:
    """Validated service configuration."""

    output_dir: Path
    interval: int
    timeout: int
    retries: int
    retry_delay: int
    cameras: tuple[Camera, ...] = field(default_factory=tuple)


def load_config(path: Path) -> Config:
    """Load and validate the YAML configuration file."""
    try:
        raw = yaml.safe_load(path.read_text(encoding="utf-8"))
    except OSError as exc:
        raise ConfigError(f"cannot read config file {path}: {exc}") from exc
    except yaml.YAMLError as exc:
        raise ConfigError(f"invalid YAML in {path}: {exc}") from exc

    if not isinstance(raw, dict):
        raise ConfigError(f"config root in {path} must be a mapping")

    output_dir = raw.get("output_dir")
    if not output_dir:
        raise ConfigError("missing required key: output_dir")

    cameras_raw = raw.get("cameras")
    if not isinstance(cameras_raw, list) or not cameras_raw:
        raise ConfigError("'cameras' must be a non-empty list")

    cameras = []
    for index, entry in enumerate(cameras_raw):
        if not isinstance(entry, dict):
            raise ConfigError(f"camera entry #{index} must be a mapping")
        name = entry.get("name")
        url = entry.get("url")
        if not name or not url:
            raise ConfigError(
                f"camera entry #{index} needs both 'name' and 'url'"
            )
        if "/" in name or name in {".", ".."}:
            raise ConfigError(f"camera name {name!r} is not a valid folder name")
        cameras.append(Camera(name=str(name), url=str(url)))

    retries = int(raw.get("retries", DEFAULT_RETRIES))
    retry_delay = int(raw.get("retry_delay", DEFAULT_RETRY_DELAY))
    if retries < 0 or retry_delay < 0:
        raise ConfigError("'retries' and 'retry_delay' must not be negative")

    return Config(
        output_dir=Path(output_dir),
        interval=int(raw.get("interval", DEFAULT_INTERVAL)),
        timeout=int(raw.get("timeout", DEFAULT_TIMEOUT)),
        retries=retries,
        retry_delay=retry_delay,
        cameras=tuple(cameras),
    )


def capture_image(camera: Camera, output_dir: Path, timeout: int) -> bool:
    """Grab a single frame from a camera stream via ffmpeg (one attempt).

    Returns True on success, False otherwise.
    """
    camera_dir = output_dir / camera.name
    camera_dir.mkdir(parents=True, exist_ok=True)

    timestamp = datetime.now().strftime(TIMESTAMP_FORMAT)
    target = camera_dir / f"{timestamp}.jpg"

    command = [
        "ffmpeg",
        "-hide_banner",
        "-loglevel", "error",
        "-y",
    ]
    if camera.url.startswith("rtsp://"):
        command += ["-rtsp_transport", "tcp"]
    command += [
        "-i", camera.url,
        "-frames:v", "1",
        "-q:v", "2",
        str(target),
    ]

    try:
        result = subprocess.run(
            command,
            check=False,
            timeout=timeout,
            capture_output=True,
            text=True,
        )
    except subprocess.TimeoutExpired:
        LOG.error("camera %s: capture timed out after %ss", camera.name, timeout)
        return False
    except FileNotFoundError:
        LOG.critical("ffmpeg binary not found in PATH")
        raise

    if result.returncode != 0:
        LOG.error(
            "camera %s: ffmpeg failed (rc=%s): %s",
            camera.name,
            result.returncode,
            result.stderr.strip(),
        )
        target.unlink(missing_ok=True)
        return False

    LOG.info("camera %s: saved %s", camera.name, target)
    return True


def capture_with_retries(
    camera: Camera, config: Config, abort: threading.Event
) -> bool:
    """Capture from one camera, retrying on failure.

    Makes up to `config.retries` extra attempts, waiting
    `config.retry_delay` seconds between them. Returns True as soon as
    one attempt succeeds, False when all attempts failed or the service
    is shutting down.
    """
    attempts = config.retries + 1
    for attempt in range(1, attempts + 1):
        if capture_image(camera, config.output_dir, config.timeout):
            return True
        if attempt < attempts:
            LOG.warning(
                "camera %s: attempt %d/%d failed, retrying in %ss",
                camera.name,
                attempt,
                attempts,
                config.retry_delay,
            )
            if abort.wait(config.retry_delay):
                return False
    LOG.error("camera %s: giving up after %d attempt(s)", camera.name, attempts)
    return False


def capture_all(config: Config, abort: threading.Event) -> int:
    """Capture one image from every configured camera.

    Returns the number of failed captures.
    """
    failures = 0
    for camera in config.cameras:
        if abort.is_set():
            break
        if not capture_with_retries(camera, config, abort):
            failures += 1
    return failures


def install_signal_handlers(shutdown: threading.Event) -> None:
    """Set the shutdown event on SIGTERM/SIGINT for a clean service stop."""

    def handle(signum: int, _frame: FrameType | None) -> None:
        LOG.info("received signal %s, shutting down", signal.Signals(signum).name)
        shutdown.set()

    signal.signal(signal.SIGTERM, handle)
    signal.signal(signal.SIGINT, handle)


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(
        description="Capture timelapse snapshots from CCTV camera streams.",
    )
    parser.add_argument(
        "-c", "--config",
        type=Path,
        default=Path("/etc/cctv-timelapse/config.yaml"),
        help="path to the YAML configuration file (default: %(default)s)",
    )
    parser.add_argument(
        "-1", "--one-shot",
        action="store_true",
        help="capture a single round of images and exit",
    )
    parser.add_argument(
        "-v", "--verbose",
        action="store_true",
        help="enable debug logging",
    )
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    """Entry point."""
    args = parse_args(argv)
    logging.basicConfig(
        level=logging.DEBUG if args.verbose else logging.INFO,
        format="%(asctime)s %(levelname)s %(message)s",
    )

    try:
        config = load_config(args.config)
    except ConfigError as exc:
        LOG.critical("configuration error: %s", exc)
        return 2

    LOG.info(
        "loaded %d camera(s), output %s, interval %ss, retries %d every %ss",
        len(config.cameras),
        config.output_dir,
        config.interval,
        config.retries,
        config.retry_delay,
    )

    shutdown = threading.Event()
    install_signal_handlers(shutdown)

    if args.one_shot:
        return 1 if capture_all(config, shutdown) else 0

    while not shutdown.is_set():
        started = time.monotonic()
        capture_all(config, shutdown)
        elapsed = time.monotonic() - started
        shutdown.wait(max(0.0, config.interval - elapsed))
    return 0


if __name__ == "__main__":
    sys.exit(main())
