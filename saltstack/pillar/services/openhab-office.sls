openhab:
  id: Openhab-office
  zigbee2mqtt:
    id: Openhab-office-zigbee2mqtt
    device: /dev/ttyUSB-Z-Stack
  mosquitto:
    id: Openhab-office-mosquitto
  tuyamqtt:
    id: False
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
    domain: z2m.home.ows
    ssl: internal
    ssl_name: home_ows
