{% import_yaml 'static.yaml' as static %}

openhab:
  id: Openhab-julia
  zigbee2mqtt:
    id: Openhab-julia-zigbee2mqtt
    device: /dev/ttyUSB-Z-Stack
  mosquitto:
    id: Openhab-julia-mosquitto
  tuyamqtt:
    id: False
  vmagent:
    id: Openhab-julia-vmagent
  influxdb:
    id: Openhab-julia-influxdb
  grafana:
    id: False
  yandex2mqtt:
    # id: Openhab-julia-yandex2mqtt
    # Not used for now
    id: False

proxy_vhosts:
  openhab:
    domain: home.j.pws
    ssl: internal
    ssl_name: j_pws
  openhab-direct:
    domain: home.j.petro.ws
    port: {{ static.proxy_ports.openhab_http }}
    ssl_force: False
    ssl: internal
    ssl_name: local
  openhab-stats:
    domain: stats.j.pws
    ssl: internal
    ssl_name: j_pws
  openhab-zigbee2mqtt:
    domain: z2m.j.pws
    ssl: internal
    ssl_name: j_pws
