openhab:
  id: Openhab-julia
  zigbee2mqtt:
    id: Openhab-julia-zigbee2mqtt
    device: /dev/serial/by-id/usb-Silicon_Labs_Sonoff_Zigbee_3.0_USB_Dongle_Plus_0001-if00-port0
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
