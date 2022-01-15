{% import_yaml 'static.yaml' as static %}

roles:
  - docker
  - nginx
  - nextcloud

nextcloud:
  version: 21.0.0-apache
  version_db: 10.5
  data_dir: /srv/nextcloud-data
  dirs:
    - data

proxy_vhosts:
  nextcloud:
    domain: nextcloud-dev.local.pws
    port: {{ static.proxy_ports.nextcloud_http }}
    ssl: internal
    ssl_name: local
    enable_dotfiles: True
