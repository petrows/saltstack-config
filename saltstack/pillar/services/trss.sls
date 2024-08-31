# Tiny-RSS (tt-rss) service
# https://tt-rss.org/wiki/InstallationNotes/
# Old web git version was: 1c7e478

{% import_yaml 'static.yaml' as static %}

roles:
  - docker
  - trss

include:
  - services.nginx

trss:
  id: Tiny-rss-dev
  # https://hub.docker.com/r/cthulhoo/ttrss-fpm-pgsql-static/tags
  version: 1fb202b2
  version_db: '16.4'
  data_dir: /srv/trss-data
  url: http://trss-dev.local.pws

proxy_vhosts:
  trss:
    domain: trss-dev.local.pws
    port: {{ static.proxy_ports.trss_http }}
    ssl: internal
    ssl_name: local
