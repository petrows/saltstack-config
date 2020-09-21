{% import_yaml 'static.yaml' as static %}

roles:
  - docker
  - nginx
  - openhab

openhab:
  id: Openhab-dev
  version: 2.5.8
  data_dir: /srv/openhab-data
  dirs:
    - /srv/openhab-data/conf
    - /srv/openhab-data/userdata
    - /srv/openhab-data/addons
    - /srv/openhab-data/java

  zigbee2mqtt:
    id: Openhab-zigbee2mqtt-dev
    version: 1.14.3
    device: ''
    data_dir: /srv/zigbee2mqtt-data
    dirs:
      - /srv/zigbee2mqtt-data

  mosquitto:
    id: Openhab-mosquitto-dev
    version: 1.4.10 # 1.6.12
    data_dir: /srv/mosquitto-data
    dirs:
      - /srv/mosquitto-data/data
      - /srv/mosquitto-data/config
      - /srv/mosquitto-data/log

  influxdb:
    id: Openhab-influxdb-dev
    version: 1.0.2 # 1.8.1
    data_dir: /srv/influxdb-data
    dirs:
      - /srv/influxdb-data

  grafana:
    id: Openhab-grafana-dev
    version: 7.1.4 # 1.8.1
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
