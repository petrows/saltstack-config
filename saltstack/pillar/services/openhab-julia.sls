{% import_yaml 'static.yaml' as static %}

openhab:
  id: Openhab-julia
  zigbee2mqtt:
    id: Openhab-julia-zigbee2mqtt
    instances:
      julia:
        topic: zigbee2mqtt
        device: usb-Silicon_Labs_Sonoff_Zigbee_3.0_USB_Dongle_Plus_0001-if00-port0
        channel: 25
        pan_id: 11426
        port: 3001
  mosquitto:
    id: Openhab-julia-mosquitto
  tuyamqtt:
    id: False
  vmagent:
    id: Openhab-julia-vmagent
  influxdb:
    id: Openhab-julia-influxdb
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
    enable_http2: True
    custom_config: |
        location /api {
            proxy_pass http://127.0.0.1:3001/api;
            proxy_set_header Host $host;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }
