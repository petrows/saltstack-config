{% import_yaml 'static.yaml' as static %}

roles:
  - docker
  - openhab

include:
  - services.nginx

openhab:
  # https://hub.docker.com/r/openhab/openhab/tags
  id: Openhab-dev
  version: 4.3.0
  data_dir: /srv/openhab-data
  dirs:
    - /srv/openhab-data/conf
    - /srv/openhab-data/userdata
    - /srv/openhab-data/addons
    - /srv/openhab-data/java

  # https://github.com/Koenkk/zigbee2mqtt/releases
  zigbee2mqtt:
    id: Openhab-zigbee2mqtt-dev
    version: 2.4.0
    device: ''
    data_dir: /srv/zigbee2mqtt-data
    dirs:
      - /srv/zigbee2mqtt-data

  # https://hub.docker.com/_/eclipse-mosquitto
  mosquitto:
    id: Openhab-mosquitto-dev
    version: 2.0.15
    data_dir: /srv/mosquitto-data
    dirs:
      - /srv/mosquitto-data/data
      - /srv/mosquitto-data/config
      - /srv/mosquitto-data/log

  tuyamqtt:
    id: Openhab-tuyamqtt-dev
    version: 3.0.4-amd64
    data_dir: /srv/openhab-data/conf/tuya-mqtt

  vmagent:
    id: Openhab-vmagent-dev
    version: 1.107.0
    # Remote URL to send data to prometheus/victoriametrics
    remote_url: https://vmagent.k8s.pws/api/v1/write
    data_dir: /srv/influxdb-vmagent-data
    dirs:
      - /srv/influxdb-vmagent-data

  influxdb:
    id: Openhab-influxdb-dev
    version: 1.8
    data_dir: /srv/influxdb-data
    dirs:
      - /srv/influxdb-data

  # Yandex2mqtt proxy
  yandex2mqtt:
    id: False # Do not start by default
    version: 0.3.3
    data_dir: /srv/yandex2mqtt-data
    dirs:
      - /srv/yandex2mqtt-data

proxy_vhosts:
  openhab:
    domain: openhab-dev.local.pws
    port: {{ static.proxy_ports.openhab_http }}
    ssl: internal
    ssl_name: local
  openhab-stats:
    domain: openhab-stats-dev.local.pws
    port: {{ static.proxy_ports.openhab_grafana }}
    ssl: internal
    ssl_name: local
    enable_frame: True
  openhab-zigbee2mqtt:
    domain: zigbee2mqtt-dev.local.pws
    port: {{ static.proxy_ports.openhab_zigbee2mqtt }}
    ssl: internal
    ssl_name: local
    enable_http2: True
    custom_config: |
        location /api {
            proxy_pass http://127.0.0.1:3001/api;
            proxy_set_header Host $host;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }
