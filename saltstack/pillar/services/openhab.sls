{% import_yaml 'static.yaml' as static %}

roles:
  - docker
  - openhab

include:
  - services.nginx

openhab:
  # https://hub.docker.com/r/openhab/openhab/tags
  id: Openhab-dev
  version: 5.0.1
  data_dir: /srv/openhab-data
  dirs:
    - /srv/openhab-data/conf
    - /srv/openhab-data/userdata
    - /srv/openhab-data/addons
    - /srv/openhab-data/java

  # https://github.com/Koenkk/zigbee2mqtt/releases
  zigbee2mqtt:
    id: Openhab-zigbee2mqtt-dev
    version: 2.6.2
    instances: {}
    data_dir: /srv/zigbee2mqtt-data

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
    remote_url: https://10.80.0.14:5959/
    data_dir: /srv/influxdb-vmagent-data
    dirs:
      - /srv/influxdb-vmagent-data

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
