{% import_yaml 'static.yaml' as static %}

roles:
  - docker
  - nginx
  - openhab

openhab:
  id: Openhab-dev
  version: 3.2.0
  data_dir: /srv/openhab-data
  dirs:
    - /srv/openhab-data/conf
    - /srv/openhab-data/userdata
    - /srv/openhab-data/addons
    - /srv/openhab-data/java

  zigbee2mqtt:
    id: Openhab-zigbee2mqtt-dev
    version: 1.24.0
    device: ''
    data_dir: /srv/zigbee2mqtt-data
    dirs:
      - /srv/zigbee2mqtt-data

  mosquitto:
    id: Openhab-mosquitto-dev
    version: 1.6
    data_dir: /srv/mosquitto-data
    dirs:
      - /srv/mosquitto-data/data
      - /srv/mosquitto-data/config
      - /srv/mosquitto-data/log

  influxdb:
    id: Openhab-influxdb-dev
    version: 1.8
    data_dir: /srv/influxdb-data
    dirs:
      - /srv/influxdb-data

  grafana:
    id: Openhab-grafana-dev
    version: 8.1.5
    data_dir: /srv/grafana-data
    dirs:
      - /srv/grafana-data

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
