{% import_yaml 'static.yaml' as static %}

roles:
  - docker
  - openhab

include:
  - services.nginx

# Required for OpenThread BorderRouter
sysctl:
  net.ipv6.conf.eth0.accept_ra: 2
  net.ipv6.conf.eth0.accept_ra_rt_info_max_plen: 64
  net.ipv6.conf.all.forwarding: 1

openhab:
  # https://hub.docker.com/r/openhab/openhab/tags
  id: Openhab-dev
  version: 5.2.0
  data_dir: /srv/openhab-data
  dirs:
    - /srv/openhab-data/conf
    - /srv/openhab-data/userdata
    - /srv/openhab-data/addons
    - /srv/openhab-data/java

  # https://github.com/Koenkk/zigbee2mqtt/releases
  zigbee2mqtt:
    id: Openhab-zigbee2mqtt-dev
    version: 2.12.1
    instances: {}
    data_dir: /srv/zigbee2mqtt-data

  # OpenThread Border Router
  otbr:
    id: False # Do not start by default
    device: usb-Itead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_V2_4aa733bc4853ef118b5c20e0174bec31-if00-port0
    # https://hub.docker.com/r/openthread/border-router/tags
    version: sha-69f03f0
    data_dir: /srv/otbr-data

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
  ota:
    domain: ota-dev.local.pws
    type: folder
    root: /srv/ota
    ssl_force: False
    ssl: internal
    ssl_name: local
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
