{% import_yaml 'static.yaml' as static %}

roles:
  - docker
  - nginx
  - nextcloud

nextcloud:
  version: 19.0.1-apache
  version_db: 10.5
  dirs:
    - /opt/nextcloud-data/data
    - /opt/nextcloud-data/db

proxy_vhosts:
  nextcloud:
    domain: nextcloud-dev.local.pws
    port: {{ static.proxy_ports.nextcloud_http }}
    ssl: internal
    ssl_name: local
