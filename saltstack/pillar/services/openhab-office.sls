openhab:
  id: Openhab-office
  zigbee2mqtt:
    id: Openhab-office-zigbee2mqtt
    device: /dev/ttyUSB-Z-Stack
  mosquitto:
    id: Openhab-office-mosquitto
  influxdb:
    id: Openhab-office-influxdb
  grafana:
    id: False

proxy_vhosts:
  openhab:
    domain: home.ows
    ssl: internal
    ssl_name: home_ows
  openhab-stats:
    domain: stats.home.ows
    ssl: internal
    ssl_name: home_ows
  openhab-zigbee2mqtt:
    domain: zigbee2mqtt.home.ows
    ssl: internal
    ssl_name: home_ows
