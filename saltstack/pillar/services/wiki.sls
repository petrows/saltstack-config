{% import_yaml 'static.yaml' as static %}

roles:
  - docker
  - wiki

include:
  - services.nginx

wiki:
  # https://hub.docker.com/_/mediawiki
  version: 1.46.0
  # https://hub.docker.com/_/mariadb
  #version_db: 12.3.2
  version_db: 10.5
  data_dir: /srv/wiki-data
  dirs:
    - /srv/wiki-data/images
    - /srv/wiki-data/extensions

proxy_vhosts:
  wiki:
    domain: wiki-dev.local.pws
    port: {{ static.proxy_ports.wiki_http }}
    ssl: internal
    ssl_name: local
