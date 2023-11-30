openhab:
  id: Openhab
  zigbee2mqtt:
    id: Openhab-zigbee2mqtt
    device: /dev/ttyUSB-Z-Stack
  mosquitto:
    id: Openhab-mosquitto
  tuyamqtt:
    id: Openhab-tuyamqtt
  influxdb:
    id: Openhab-influxdb
  grafana:
    id: Openhab-grafana
  yandex2mqtt:
    id: Openhab-yandex2mqtt

proxy_vhosts:
  openhab:
    domain: home.pws
    ssl: internal
    ssl_name: home
  openhab-stats:
    domain: stats.home.pws
    ssl: internal
    ssl_name: home
  openhab-zigbee2mqtt:
    domain: z2m.home.pws
    ssl: internal
    ssl_name: home
  yandex2mqtt:
    domain: y2m.petro.ws
    ssl: external
