#!/usr/bin/env python3

import argparse
import subprocess
import ssl
import time
import yaml
import json
import requests
import paho.mqtt.client as mqtt
import logging
from datetime import datetime
from ftplib import FTP_TLS
from pathlib import Path
import systemd.daemon

STATE_IDLE = "IDLE"
STATE_PRINTING = "RUNNING"
STATE_FINISHED = "FINISH"

class BambuWatcher:
    def __init__(self, config):
        self.cfg = config
        self.last_state = STATE_FINISHED
        self.last_temp = None
        self.last_progress = None
        self.current_job = None

        self.print_file = None
        self.print_task = None
        self.print_nozzle_size = None
        self.print_start_time = None
        self.print_layers = None

        self.bambu_connected = False
        self.bambu_loop_started = False
        self.last_seen_time = None
        # Count idle from startup; reset to None when printer becomes active
        self.idle_start_time = time.time()

        # Bambu MQTT client setup
        self.client = mqtt.Client(
            client_id=f"bambu-watcher"
        )
        self.client.username_pw_set(
            config["bambu"]["username"],
            config["bambu"]["access_code"]
        )
        self.client.tls_set(cert_reqs=ssl.CERT_NONE)
        self.client.tls_insecure_set(True)
        self.client.on_connect = self.on_connect
        self.client.on_disconnect = self.on_disconnect
        self.client.on_message = self.on_message

        # Smarthome metrics mqtt client setup
        self.smarthome_last_mqtt_publish = 0
        self.smarthome_client = mqtt.Client(
            client_id=f"bambu-watcher-smarthome"
        )
        self.smarthome_client.username_pw_set(
            self.cfg["mqtt_report"]["username"],
            self.cfg["mqtt_report"]["password"]
        )

    def connect(self):
        # Connect to Smarthome MQTT broker
        self.smarthome_client.connect(
            self.cfg["mqtt_report"]["host"],
            self.cfg["mqtt_report"]["port"],
            keepalive=60
        )
        self.smarthome_client.loop_start()

    def try_connect_bambu(self):
        """Attempt connection to Bambu printer MQTT. Returns True if initiated."""
        try:
            self.client.connect(
                self.cfg["bambu"]["host"],
                self.cfg["bambu"]["mqtt_port"],
                keepalive=60
            )
            if not self.bambu_loop_started:
                self.client.loop_start()
                self.bambu_loop_started = True
            logging.info("Bambu MQTT connection attempt initiated")
            return True
        except Exception as e:
            logging.warning("Bambu MQTT connect failed: %s", e)
            return False

    def on_connect(self, client, userdata, flags, rc):
        if rc == 0:
            self.bambu_connected = True
            topic = f"device/{self.cfg['bambu']['serial']}/report"
            client.subscribe(topic)
            logging.info(f"Subscribed to {topic}")
        else:
            logging.warning("Bambu MQTT connect rejected, rc=%d", rc)

    def on_disconnect(self, client, userdata, rc):
        self.bambu_connected = False
        self.idle_start_time = None
        logging.warning("Disconnected from Bambu printer (rc=%d)", rc)

    def on_message(self, client, userdata, msg):
        self.last_seen_time = time.time()

        payload = json.loads(msg.payload.decode())
        logging.debug("Received message: %s", msg.payload.decode())

        if "print" not in payload:
            logging.debug("No print data in payload")
            return

        p = payload["print"]
        state = p.get("gcode_state")

        if not state:
            logging.debug("Invalid print state")
            return

        self.print_id = p.get("job_id")
        self.print_file = p.get("file")
        self.print_task = p.get("subtask_name")
        self.print_nozzle_size = p.get("nozzle_diameter")
        self.print_layers = p.get("total_layer_num")

        # We have to filter metrics, as printer sends it too frequently (about every second)

        current_time = time.time()
        should_publish = (current_time - self.smarthome_last_mqtt_publish >= 60)

        current_progress = p.get("percent")
        current_temp = p.get("nozzle_temper")

        if self.last_progress != current_progress:
            logging.info(f"Progress changed: {self.last_progress} → {current_progress}")
            should_publish = True

        if self.last_temp != current_temp:
            logging.info(f"Temperature changed: {self.last_temp} → {current_temp}")
            should_publish = True

        self.last_progress = current_progress
        self.last_temp = current_temp

        if state != self.last_state:
            logging.info(f"State changed: {self.last_state} → {state}")
            should_publish = True

            if state == STATE_PRINTING:
                self.print_start_time = time.time()

            if self.last_state == STATE_PRINTING and state == STATE_FINISHED:
                self.on_print_finished()

            self.last_state = state

        # Check the dry status
        # $.print.ams.ams[1].dry_setting.dry_temperature
        is_drying = False
        ams_list = list()
        try:
            ams_list = p["ams"]["ams"]
        except (KeyError, IndexError, TypeError):
            logging.debug("No AMS data present")
        if ams_list:
            for ams in ams_list:
                # Get current dry temperature, should be > 0, if dry is active
                dry_temp = -1
                try:
                    dry_temp = ams["dry_setting"]["dry_temperature"]
                except (KeyError, IndexError, TypeError):
                    logging.debug("No AMS dry setting present")
                logging.debug("AMS dry temp: %d", dry_temp)
                if dry_temp > 0:
                    is_drying = True

        # Track idle time: active only while RUNNING (printing or drying)
        if state == STATE_PRINTING or is_drying:
            if self.idle_start_time is not None:
                logging.info("Printer became active, idle timer reset")
            self.idle_start_time = None
        elif self.idle_start_time is None:
            self.idle_start_time = current_time
            logging.info("Printer became idle, idle timer started")

        if should_publish:
            idle_seconds = int(current_time - self.idle_start_time) if self.idle_start_time is not None else 0
            publish_payload = dict(payload)
            publish_payload["_meta"] = {
                "printer_connected": True,
                "printer_drying": is_drying,
                "idle_seconds": idle_seconds,
            }
            smarthome_topic = f"{self.cfg['mqtt_report']['topic']}/status"
            ret = self.smarthome_client.publish(smarthome_topic, json.dumps(publish_payload), retain=True)
            logging.debug(f"Published to {smarthome_topic}, result: {ret}")
            self.smarthome_last_mqtt_publish = current_time
            # Dump file
            dump_filename = f"dumps/payload-{self.print_id}-{state}.json"
            with open(dump_filename, "w") as f:
                json.dump(publish_payload, f, indent=2)

    def publish_disconnected_status(self):
        # Stop Idle timer (we dont track idle for disconnected device)
        self.idle_start_time = None
        now = time.time()
        meta = {
            "printer_connected": False,
            "idle_seconds": -1,
        }
        if self.last_seen_time is not None:
            meta["last_seen_seconds"] = int(now - self.last_seen_time)
            meta["last_seen_datetime"] = datetime.fromtimestamp(self.last_seen_time).isoformat()

        topic = f"{self.cfg['mqtt_report']['topic']}/status"
        self.smarthome_client.publish(topic, json.dumps({"_meta": meta}), retain=True)
        logging.info("Published disconnected printer status")

    def on_print_finished(self):
        logging.info("Print finished")

        if self.print_start_time:
            duration = int(time.time() - self.print_start_time)
            hours = duration // 3600
            minutes = (duration % 3600) // 60
            seconds = duration % 60
            print_duration = f"{hours:02d}:{minutes:02d}:{seconds:02d}"
        else:
            print_duration = "Unknown"

        # Retry logic for snapshot fetch
        max_retries = 5
        for attempt in range(max_retries):
            try:
                image = self.fetch_snapshot_ffmpeg()
                break
            except Exception as e:
                logging.warning(f"Snapshot fetch attempt {attempt + 1}/{max_retries} failed: {e}")
            if attempt < max_retries - 1:
                time.sleep(10)
            else:
                logging.error("All snapshot fetch attempts failed")
                image = None

        text = f"✅ Print done!\n\nTime: `{print_duration}`\nTask: `{self.print_task}`\nNozzle: `{self.print_nozzle_size}` mm\nLayers: `{self.print_layers}`"

        for attempt in range(max_retries):
            try:
                self.send_telegram(text, image)
                break
            except Exception as e:
                logging.warning(f"Telegram send attempt {attempt + 1}/{max_retries} failed: {e}")
            if attempt < max_retries - 1:
                time.sleep(10)
            else:
                logging.error("All Telegram send attempts failed")

    def fetch_snapshot_ffmpeg(self):
        logging.info("Fetching snapshot via FFmpeg from RTSP stream")
        tmpdir = "/tmp"
        img_path = Path(tmpdir) / "snapshot-bot.jpg"
        rtsp_url = f"rtsps://bblp:{self.cfg["bambu"]["access_code"]}@{self.cfg["bambu"]["host"]}:322/streaming/live/1"

        cmd = [
            "ffmpeg",
            "-y",
            "-rtsp_transport", "tcp",
            "-i", rtsp_url,
            "-frames:v", "1",
            "-q:v", "2",
            str(img_path)
        ]

        try:
            subprocess.run(
                cmd,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                timeout=10,
                check=True
            )
            return img_path.read_bytes()
        except Exception as e:
            logging.error("FFmpeg snapshot error: %s", e)
            return None

    def send_telegram(self, text, image_bytes):
        if not self.cfg.get("telegram"):
            logging.warning("Telegram config not found, skipping notification")
            return

        token = self.cfg["telegram"]["bot_token"]
        chat_id = self.cfg["telegram"]["chat_id"]

        if image_bytes:
            url = f"https://api.telegram.org/bot{token}/sendPhoto"
            files = {"photo": image_bytes}
            data = {
                "chat_id": chat_id,
                "caption": text,
                "parse_mode": "Markdown"
            }
            requests.post(url, data=data, files=files)
        else:
            url = f"https://api.telegram.org/bot{token}/sendMessage"
            data = {
                "chat_id": chat_id,
                "text": text,
                "parse_mode": "Markdown"
            }
            requests.post(url, data=data)

    def send_telegram_video(self, text, video_bytes):
        token = self.cfg["telegram"]["bot_token"]
        chat_id = self.cfg["telegram"]["chat_id"]

        url = f"https://api.telegram.org/bot{token}/sendVideo"
        files = {"video": video_bytes}
        data = {
            "chat_id": chat_id,
            "caption": text,
            "supports_streaming": True
        }

        requests.post(url, data=data, files=files)

def load_config(path: Path):
    with open(path, "r") as f:
        return yaml.safe_load(f)

def main():

    parser = argparse.ArgumentParser(
        description='Bambu Bot - Monitor Bambu Lab printers and send Telegram notifications'
    )

    parser.add_argument(
        '-l', '--log',
        choices=['DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL'],
        type=str.upper,
        default='INFO',
        help='set log level',
    )

    parser.add_argument(
        '--cfg',
        default="bambu.yaml",
        help='path to yaml config file',
    )

    args = parser.parse_args()

    log_level = args.log
    logging.basicConfig(level=log_level)

    logging.debug("Config path %s", args.cfg)

    cfg = load_config(Path(args.cfg))
    watcher = BambuWatcher(cfg)
    watcher.connect()  # smarthome MQTT only

    systemd.daemon.notify('READY=1')

    last_bambu_connect_attempt = 0  # triggers immediately on first iteration
    last_disconnected_publish = 0

    try:
        while True:
            now = time.time()

            if not watcher.bambu_connected:
                # paho-mqtt auto-reconnects once the loop is started;
                # manual retry only needed before first successful connect
                if not watcher.bambu_loop_started and (now - last_bambu_connect_attempt >= 60):
                    last_bambu_connect_attempt = now
                    watcher.try_connect_bambu()

                if now - last_disconnected_publish >= 60:
                    last_disconnected_publish = now
                    watcher.publish_disconnected_status()

            time.sleep(cfg["service"]["poll_interval_sec"])
    except KeyboardInterrupt:
        print("Stopping service")

if __name__ == "__main__":
    main()
