openhab:
  id: Openhab-julia
  zigbee2mqtt:
    id: Openhab-julia-zigbee2mqtt
    device: /dev/ttyUSB-Z-Stack
  mosquitto:
    id: Openhab-julia-mosquitto
  tuyamqtt:
    id: False
  influxdb:
    id: Openhab-julia-influxdb
  grafana:
    id: False

proxy_vhosts:
  openhab:
    domain: home.j.pws
    ssl: internal
    ssl_name: j_pws
  openhab-stats:
    domain: stats.j.pws
    ssl: internal
    ssl_name: j_pws
  openhab-zigbee2mqtt:
    domain: z2m.j.pws
    ssl: internal
    ssl_name: j_pws
