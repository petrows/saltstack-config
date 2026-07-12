#!/usr/bin/env python3
"""Claude Usage -> MQTT Bridge.

Polls the undocumented Anthropic endpoint
``GET https://api.anthropic.com/api/oauth/usage``
(Pro/Max subscription limits: 5-hour session + weekly windows)
and publishes the data to an MQTT broker for a DIY device.

Requirements:
    pip install paho-mqtt
    Claude Code (claude-cli) installed and logged in:
    the OAuth token is read from ``~/.claude/.credentials.json``.

Example:
    python3 claude_usage_mqtt.py --host 192.168.1.10 --user iot --password s3cret

Published topics (retain=True):
    <base>/json                     -- the whole snapshot as one JSON
    <base>/<window>/used_pct        -- consumed, %
    <base>/<window>/remaining_pct   -- remaining, %
    <base>/<window>/resets_at       -- ISO time when the window resets
    <base>/availability             -- "online"/"offline" (LWT)
    <base>/error                    -- text of the last error ("" if OK)
where <window> is: session_5h, week_all, week_sonnet, week_opus.

Warning: the endpoint is unofficial and aggressively rate-limited,
do not set ``--interval`` below ~120 seconds.
"""

from __future__ import annotations

import argparse
import json
import logging
import re
import shutil
import subprocess
import time
import urllib.error
import urllib.request
from pathlib import Path
from typing import Any, Optional

import paho.mqtt.client as mqtt

USAGE_URL = "https://api.anthropic.com/api/oauth/usage"
OAUTH_BETA_HEADER = "oauth-2025-04-20"
FALLBACK_CLI_VERSION = "2.1.0"
MAX_BACKOFF_SECONDS = 1800

#: mapping of Anthropic response fields to topic names
WINDOWS = {
    "five_hour": "session_5h",
    "seven_day": "week_all",
    "seven_day_sonnet": "week_sonnet",
    "seven_day_opus": "week_opus",
}

LOG = logging.getLogger("claude-usage-mqtt")


def parse_args() -> argparse.Namespace:
    """Parses command-line arguments."""
    parser = argparse.ArgumentParser(
        description="Publishes Claude (Pro/Max) limits to MQTT.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument("--host", required=True, help="MQTT broker address")
    parser.add_argument("--port", type=int, default=1883, help="broker port")
    parser.add_argument("--user", default="", help="MQTT login (empty = no authentication)")
    parser.add_argument("--password", default="", help="MQTT password")
    parser.add_argument("--tls", action="store_true", help="use TLS (usually port 8883)")
    parser.add_argument("--client-id", default="claude-usage-bridge", help="MQTT client id")
    parser.add_argument("--base-topic", default="claude/usage", help="base topic")
    parser.add_argument(
        "--interval",
        type=int,
        default=180,
        help="Anthropic polling period, seconds (do not set below ~120)",
    )
    parser.add_argument(
        "--credentials",
        type=Path,
        default=Path.home() / ".claude" / ".credentials.json",
        help="path to the Claude Code credentials file",
    )
    parser.add_argument(
        "--cli-version",
        default=None,
        help="claude-cli version for the User-Agent (auto-detected by default)",
    )
    parser.add_argument("-v", "--verbose", action="store_true", help="verbose logging")
    args = parser.parse_args()
    if args.interval < 120:
        parser.error("--interval below 120 s will almost certainly lead to HTTP 429")
    return args


def detect_cli_version() -> str:
    """Returns the installed claude-cli version (for the User-Agent header).

    Without the ``User-Agent: claude-code/<version>`` header the endpoint
    responds with constant 429s, so the version matters.
    """
    executable = shutil.which("claude")
    if executable is None:
        LOG.warning(
            "claude-cli not found in PATH, using version %s", FALLBACK_CLI_VERSION
        )
        return FALLBACK_CLI_VERSION
    try:
        result = subprocess.run(
            [executable, "--version"],
            capture_output=True,
            text=True,
            timeout=15,
            check=True,
        )
    except (OSError, subprocess.SubprocessError) as exc:
        LOG.warning(
            "failed to run 'claude --version' (%s), using %s",
            exc,
            FALLBACK_CLI_VERSION,
        )
        return FALLBACK_CLI_VERSION
    match = re.search(r"\d+\.\d+\.\d+", result.stdout or result.stderr)
    if match is None:
        LOG.warning(
            "could not recognize a version in the claude-cli output, using %s",
            FALLBACK_CLI_VERSION,
        )
        return FALLBACK_CLI_VERSION
    LOG.info("claude-cli version: %s", match.group(0))
    return match.group(0)


def read_access_token(credentials_path: Path) -> str:
    """Reads the OAuth token that Claude Code stores and refreshes itself."""
    with credentials_path.open(encoding="utf-8") as file:
        creds = json.load(file)
    oauth = creds.get("claudeAiOauth", creds)
    token = oauth.get("accessToken")
    if not token:
        raise RuntimeError(f"accessToken not found in {credentials_path}")
    expires_at = oauth.get("expiresAt")  # epoch in milliseconds
    if expires_at and time.time() * 1000 > expires_at:
        raise RuntimeError(
            "OAuth token has expired. Open Claude Code and send any "
            "message — it will refresh the token automatically."
        )
    return token


def fetch_usage(credentials_path: Path, cli_version: str) -> dict[str, Any]:
    """Requests raw limit data from Anthropic."""
    request = urllib.request.Request(
        USAGE_URL,
        headers={
            "Authorization": f"Bearer {read_access_token(credentials_path)}",
            "anthropic-beta": OAUTH_BETA_HEADER,
            "User-Agent": f"claude-code/{cli_version}",
            "Content-Type": "application/json",
        },
        method="GET",
    )
    with urllib.request.urlopen(request, timeout=15) as response:
        return json.loads(response.read().decode("utf-8"))


def simplify(raw: dict[str, Any]) -> dict[str, Any]:
    """Converts the Anthropic response into a compact format for the device.

    The ``utilization`` field in the response is the consumed percentage (0-100).
    """
    result: dict[str, Any] = {}
    for source, target in WINDOWS.items():
        window = raw.get(source)
        if not window:
            result[target] = None
            continue
        used = float(window.get("utilization") or 0)
        result[target] = {
            "used_pct": round(used, 1),
            "remaining_pct": round(max(0.0, 100.0 - used), 1),
            "resets_at": window.get("resets_at"),
        }
    result["fetched_at"] = int(time.time())
    return result


def make_client(args: argparse.Namespace) -> mqtt.Client:
    """Creates and connects an MQTT client with an LWT availability status."""
    client = mqtt.Client(
        mqtt.CallbackAPIVersion.VERSION2, client_id=args.client_id
    )
    if args.user:
        client.username_pw_set(args.user, args.password)
    if args.tls:
        client.tls_set()
    # LWT: if the bridge dies, the broker itself tells the device "offline".
    client.will_set(f"{args.base_topic}/availability", "offline", qos=1, retain=True)
    client.connect(args.host, args.port, keepalive=60)
    client.loop_start()  # background thread: reconnects, pings
    client.publish(f"{args.base_topic}/availability", "online", qos=1, retain=True)
    return client


def publish_snapshot(client: mqtt.Client, base_topic: str, data: dict[str, Any]) -> None:
    """Publishes a limits snapshot: the combined JSON plus individual topics."""
    client.publish(
        f"{base_topic}/json",
        json.dumps(data, ensure_ascii=False),
        qos=1,
        retain=True,
    )
    for target in WINDOWS.values():
        window = data.get(target)
        if not window:
            continue
        for key in ("used_pct", "remaining_pct", "resets_at"):
            client.publish(
                f"{base_topic}/{target}/{key}", str(window[key]), qos=1, retain=True
            )


def poll_once(
    client: mqtt.Client, args: argparse.Namespace, cli_version: str
) -> Optional[int]:
    """One poll-and-publish cycle.

    Returns the pause ceiling in seconds on HTTP 429, otherwise ``None``.
    """
    try:
        data = simplify(fetch_usage(args.credentials, cli_version))
    except urllib.error.HTTPError as exc:
        message = f"HTTP {exc.code}: {exc.reason}"
        client.publish(f"{args.base_topic}/error", message, qos=1, retain=True)
        LOG.error("request error: %s", message)
        return MAX_BACKOFF_SECONDS if exc.code == 429 else None
    except (OSError, ValueError, RuntimeError) as exc:
        client.publish(f"{args.base_topic}/error", str(exc), qos=1, retain=True)
        LOG.error("error: %s", exc)
        return None

    publish_snapshot(client, args.base_topic, data)
    client.publish(f"{args.base_topic}/error", "", qos=1, retain=True)
    session = data.get("session_5h") or {}
    week = data.get("week_all") or {}
    LOG.info(
        "ok: session %s%% left, week %s%% left",
        session.get("remaining_pct", "?"),
        week.get("remaining_pct", "?"),
    )
    return None


def main() -> None:
    """Entry point: loop of polling Anthropic and publishing to MQTT."""
    args = parse_args()
    logging.basicConfig(
        level=logging.DEBUG if args.verbose else logging.INFO,
        format="%(asctime)s %(levelname)s %(message)s",
        datefmt="%H:%M:%S",
    )
    cli_version = args.cli_version or detect_cli_version()
    LOG.info("MQTT: %s:%s, topics under '%s/'", args.host, args.port, args.base_topic)
    LOG.info("polling Anthropic every %s s.", args.interval)

    client = make_client(args)
    backoff = args.interval
    while True:
        rate_limit_cap = poll_once(client, args, cli_version)
        if rate_limit_cap is not None:
            # 429: double the pause, but no more than half an hour
            backoff = min(backoff * 2, rate_limit_cap)
            LOG.warning("rate-limited, next attempt in %s s.", backoff)
        else:
            backoff = args.interval
        time.sleep(backoff)


if __name__ == "__main__":
    main()
