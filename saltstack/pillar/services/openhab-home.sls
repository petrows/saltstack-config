openhab:
  id: Openhab
  zigbee2mqtt:
    id: Openhab-zigbee2mqtt
    device: /dev/ttyUSB-Z-Stack
  mosquitto:
    id: Openhab-mosquitto
  influxdb:
    id: Openhab-influxdb
  grafana:
    id: Openhab-grafana

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
    domain: zigbee2mqtt.home.pws
    ssl: internal
    ssl_name: home
