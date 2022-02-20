{% import_yaml 'static.yaml' as static %}

roles:
  - docker
  - nginx
  - nextcloud

nextcloud:
  # https://hub.docker.com/_/nextcloud?tab=tags
  version: 23.0.2-apache
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
