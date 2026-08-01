#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
pawfit2mqtt — считывает данные трекера Pawfit из облака Latsen и публикует их в MQTT.

У Pawfit нет официального публичного API: приложение общается со скрытым API,
который был отреверсен сообществом (проект dansbaker/homeassistant-pawfit).
Этот скрипт повторяет ту же схему авторизации и запросов, но без Home Assistant.

Публикуется на каждый трекер:
    <prefix>/<tracker_id>/state       — JSON со всеми полями
    <prefix>/<tracker_id>/latitude    — широта
    <prefix>/<tracker_id>/longitude   — долгота
    <prefix>/<tracker_id>/battery     — уровень батареи (%)
    <prefix>/<tracker_id>/signal      — уровень сигнала
    <prefix>/<tracker_id>/accuracy    — точность (м)
    <prefix>/<tracker_id>/last_update — время последнего фикса (мс, UTC)
    <prefix>/<tracker_id>/name        — имя питомца/трекера
    <prefix>/status                   — online / offline (LWT)

⚠️  Используйте ОТДЕЛЬНЫЙ аккаунт Pawfit (расшарьте на него питомцев с основного).
    Если войти под основным аккаунтом, приложение на телефоне будет постоянно
    разлогиниваться при каждом опросе — можно потерять питомца в критический момент.

Зависимости:
    pip install requests paho-mqtt

Пример:
    ./pawfit2mqtt.py \
        --pawfit-user secondary@example.com --pawfit-pass 'ПАРОЛЬ' \
        --mqtt-host 192.168.1.10 --mqtt-user mqtt --mqtt-pass secret \
        --interval 60 -v
"""

import argparse
import hashlib
import json
import logging
import signal
import sys
import time
import systemd.daemon

try:
    import requests
except ImportError:
    sys.exit("Нужен пакет requests:  pip install requests")

try:
    import paho.mqtt.client as mqtt
except ImportError:
    sys.exit("Нужен пакет paho-mqtt:  pip install paho-mqtt")


# --- Константы API (из Pawfit Android APK v3.3.0, эндпоинт api/v1) ----------
BASE_URL = "https://pawfitapi.latsen.com/api/v1/"
USER_AGENT = "Pawfit/3 CFNetwork/1390 Darwin/22.0.0"
# Секретный ключ подписи, извлечён из com.latsen.pawfit.common.base.Const.g()
PAWFIT_SECRET = "ldjou32rweo$#runvjvn@!pzm"

log = logging.getLogger("pawfit2mqtt")


def _sha256(s: str) -> str:
    return hashlib.sha256(s.encode("utf-8")).hexdigest()


class PawfitClient:
    """Синхронный клиент отреверсенного облачного API Pawfit."""

    def __init__(self, username: str, password: str):
        self.username = username
        self.password = password
        self.user_id = None
        self.session_id = None
        self.http = requests.Session()
        self.http.headers.update({"User-Agent": USER_AGENT})

    # -- подпись -----------------------------------------------------------
    def _login_sign(self, ts_ms: int) -> str:
        # SHA256(timestamp + account + password + SECRET)
        return _sha256(f"{ts_ms}{self.username}{self.password}{PAWFIT_SECRET}")

    def _api_sign(self, identity="", target="", tracker="", pet="") -> str:
        # SHA256(sessionId + userId + identity + target + tracker + pet + SECRET)
        return _sha256(
            f"{self.session_id}{self.user_id}{identity}{target}{tracker}{pet}{PAWFIT_SECRET}"
        )

    def _auth_url(self, endpoint: str) -> str:
        """Приклеивает /userId/sessionId к пути эндпоинта."""
        if not self.user_id or not self.session_id:
            raise RuntimeError("Не авторизован — сначала login()")
        base = BASE_URL + endpoint.rstrip("/")
        return f"{base}/{self.user_id}/{self.session_id}"

    # -- авторизация -------------------------------------------------------
    def login(self) -> None:
        ts = int(time.time() * 1000)
        url = BASE_URL + "login/1/1"
        data = {
            "user": self.username,
            "pwd": self.password,
            "t": str(ts),
            "sign": self._login_sign(ts),
        }
        headers = {"Content-Type": "application/x-www-form-urlencoded; charset=utf-8"}
        log.debug("Логин: %s user=%s", url, self.username)
        resp = self.http.post(url, data=data, headers=headers, timeout=30)
        if resp.status_code != 200:
            raise RuntimeError(f"Логин HTTP {resp.status_code}: {resp.text[:200]}")
        payload = resp.json()
        if not payload.get("success"):
            raise RuntimeError(f"Логин отклонён: {payload}")
        d = payload.get("data", {})
        self.user_id = str(d.get("userId") or "")
        self.session_id = str(d.get("sessionId") or "")
        if not self.user_id or not self.session_id:
            raise RuntimeError(f"Нет userId/sessionId в ответе: {payload}")
        log.info("Авторизация успешна (userId=%s)", self.user_id)

    def _get(self, endpoint: str, params=None, sign_kwargs=None):
        """GET с подписью и автоповтором логина при 403."""
        params = dict(params or {})
        params["sign"] = self._api_sign(**(sign_kwargs or {}))
        url = self._auth_url(endpoint)
        resp = self.http.get(url, params=params, timeout=30)
        if resp.status_code == 403:
            log.warning("403 — переавторизация")
            self.login()
            params["sign"] = self._api_sign(**(sign_kwargs or {}))
            url = self._auth_url(endpoint)
            resp = self.http.get(url, params=params, timeout=30)
        resp.raise_for_status()
        return resp.json()

    # -- данные ------------------------------------------------------------
    def get_trackers(self) -> dict:
        """Возвращает {tracker_id: {'name':..., 'petId':...}}."""
        if not self.user_id:
            self.login()
        payload = self._get("listpetinvitee/1/1")
        result = {}
        data = payload.get("data", {})
        items = data.items() if isinstance(data, dict) else (
            (i.get("tracker_id") or i.get("id") or i.get("trackerId"), i)
            for i in data if isinstance(i, dict)
        )
        for tid, item in items:
            if tid is None or not isinstance(item, dict):
                continue
            result[str(tid)] = {
                "name": item.get("name"),
                "petId": item.get("petId"),
            }
        return result

    def get_locations(self, tracker_ids) -> dict:
        """Возвращает {tracker_id: {latitude, longitude, accuracy, battery, signal, last_update}}."""
        if not self.user_id:
            self.login()
        ids = ",".join(str(t) for t in tracker_ids)
        payload = self._get("getlocationcaches/1/1", params={"trackers": ids})
        out = {}
        data = payload.get("data", {})
        rows = data.items() if isinstance(data, dict) else (
            (r.get("tracker") or r.get("tracker_id") or r.get("id") or r.get("trackerId"), r)
            for r in data if isinstance(r, dict)
        )
        for tid, loc in rows:
            if tid is None or not isinstance(loc, dict):
                continue
            state = loc.get("state", {}) or {}
            location = state.get("location", {}) or {}
            out[str(tid)] = {
                "latitude": location.get("latitude"),
                "longitude": location.get("longitude"),
                "accuracy": location.get("accuracy"),
                "battery": state.get("power"),
                "signal": state.get("signal"),
                "last_update": state.get("utcDateTime"),
            }
        return out


def build_mqtt_client(args) -> mqtt.Client:
    """Создаёт MQTT-клиент, совместимый с paho 1.x и 2.x."""
    status_topic = f"{args.mqtt_topic}/status"
    client_id = args.mqtt_client_id or f"pawfit2mqtt-{int(time.time())}"
    try:  # paho-mqtt >= 2.0
        client = mqtt.Client(
            mqtt.CallbackAPIVersion.VERSION2, client_id=client_id
        )
    except (AttributeError, TypeError):  # paho-mqtt 1.x
        client = mqtt.Client(client_id=client_id)

    if args.mqtt_user:
        client.username_pw_set(args.mqtt_user, args.mqtt_pass or None)
    if args.mqtt_tls:
        client.tls_set()

    client.will_set(status_topic, "offline", qos=args.qos, retain=True)

    def on_connect(client, *_):
        log.info("MQTT подключён к %s:%s", args.mqtt_host, args.mqtt_port)
        client.publish(status_topic, "online", qos=args.qos, retain=True)

    def on_disconnect(client, *_):
        log.warning("MQTT отключён")

    client.on_connect = on_connect
    client.on_disconnect = on_disconnect
    client.reconnect_delay_set(min_delay=1, max_delay=60)
    client.connect(args.mqtt_host, args.mqtt_port, keepalive=60)
    client.loop_start()
    return client


def publish_cycle(pawfit: PawfitClient, client: mqtt.Client, args, names: dict):
    tracker_ids = args.tracker or list(names.keys())
    if not tracker_ids:
        log.warning("Нет трекеров для опроса")
        return
    locations = pawfit.get_locations(tracker_ids)
    base = args.mqtt_topic
    now_ms = int(time.time() * 1000)

    for tid in tracker_ids:
        data = locations.get(str(tid))
        if not data:
            log.warning("Трекер %s: нет данных о местоположении", tid)
            continue
        data = dict(data)
        data["name"] = names.get(str(tid), {}).get("name")
        data["tracker_id"] = str(tid)
        data["polled_at"] = now_ms

        client.publish(f"{base}/{tid}/state", json.dumps(data, ensure_ascii=False),
                       qos=args.qos, retain=args.retain)
        if not args.json_only:
            for key in ("latitude", "longitude", "battery", "signal",
                        "accuracy", "last_update", "name"):
                val = data.get(key)
                if val is not None:
                    client.publish(f"{base}/{tid}/{key}", str(val),
                                   qos=args.qos, retain=args.retain)
        log.info("Трекер %s (%s): lat=%s lon=%s bat=%s%% sig=%s",
                 tid, data.get("name"), data.get("latitude"),
                 data.get("longitude"), data.get("battery"), data.get("signal"))


def parse_args(argv=None):
    p = argparse.ArgumentParser(
        description="Считывает трекер Pawfit из облака и публикует в MQTT.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    g = p.add_argument_group("Pawfit")
    g.add_argument("--pawfit-user", required=True, help="E-mail аккаунта Pawfit (лучше отдельного!)")
    g.add_argument("--pawfit-pass", required=True, help="Пароль аккаунта Pawfit")
    g.add_argument("--tracker", action="append", default=[],
                   help="ID трекера (можно повторять). По умолчанию — все с аккаунта")

    m = p.add_argument_group("MQTT")
    m.add_argument("--mqtt-host", default="localhost")
    m.add_argument("--mqtt-port", type=int, default=1883)
    m.add_argument("--mqtt-user", default=None)
    m.add_argument("--mqtt-pass", default=None)
    m.add_argument("--mqtt-topic", default="pawfit", help="Префикс топиков")
    m.add_argument("--mqtt-client-id", default=None)
    m.add_argument("--mqtt-tls", action="store_true", help="Включить TLS")
    m.add_argument("--qos", type=int, choices=(0, 1, 2), default=0)
    m.add_argument("--retain", action="store_true", help="Публиковать с retain")
    m.add_argument("--json-only", action="store_true",
                   help="Публиковать только JSON в .../state, без отдельных подтопиков")

    p.add_argument("--interval", type=int, default=60, help="Интервал опроса, сек")
    p.add_argument("--once", action="store_true", help="Один цикл и выход (для cron)")
    p.add_argument("-v", "--verbose", action="count", default=0, help="-v / -vv")
    return p.parse_args(argv)


def main(argv=None):
    args = parse_args(argv)
    level = logging.WARNING - min(args.verbose, 2) * 10  # -v=INFO, -vv=DEBUG
    logging.basicConfig(level=level, format="%(asctime)s %(levelname)s %(message)s")

    pawfit = PawfitClient(args.pawfit_user, args.pawfit_pass)
    pawfit.login()
    names = pawfit.get_trackers()
    log.info("Найдено трекеров: %d — %s",
             len(names), ", ".join(f"{k}:{v.get('name')}" for k, v in names.items()) or "—")

    client = build_mqtt_client(args)

    systemd.daemon.notify('READY=1')

    running = {"go": True}
    def stop(*_):
        running["go"] = False
    signal.signal(signal.SIGINT, stop)
    signal.signal(signal.SIGTERM, stop)

    try:
        while running["go"]:
            try:
                publish_cycle(pawfit, client, args, names)
            except Exception as e:  # не роняем демон из-за разовой сетевой ошибки
                log.error("Ошибка цикла опроса: %s", e)
            if args.once:
                break
            # спим интервал, но реагируем на сигнал завершения
            for _ in range(args.interval):
                if not running["go"]:
                    break
                time.sleep(1)
    finally:
        try:
            client.publish(f"{args.mqtt_topic}/status", "offline", qos=args.qos, retain=True)
            time.sleep(0.2)
            client.loop_stop()
            client.disconnect()
        except Exception:
            pass
    return 0


if __name__ == "__main__":
    sys.exit(main())
