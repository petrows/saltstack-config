{% import_yaml 'static.yaml' as static %}

roles:
  - docker
  - nginx
  - nextcloud

nextcloud:
  version: 19.0.1-apache
  version_db: 10.5
  data_dir: /srv/nextcloud-data
  dirs:
    - /srv/nextcloud-data/data
    - /srv/nextcloud-data/db

proxy_vhosts:
  nextcloud:
    domain: nextcloud-dev.local.pws
    port: {{ static.proxy_ports.nextcloud_http }}
    ssl: internal
    ssl_name: local
