{% import_yaml 'static.yaml' as static %}

roles:
  - docker
  - nextcloud

include:
  - services.nginx

nextcloud:
  # https://hub.docker.com/_/nextcloud?tab=tags
  version: 28.0.5-apache
  version_db: 10.10.2
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

systemd-cron:
  nextcloud-cron:
    user: root
    calendar: '*-*-* *:00/5:00'
    cwd: /
    cmd: docker exec -u 33:33 nextcloud-app php cron.php
