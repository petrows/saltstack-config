{% import_yaml 'static.yaml' as static %}

roles:
  - docker
  - firefly

include:
  - services.nginx

packages:
  - jq

firefly:
  id: Firefly-dev

  # https://hub.docker.com/r/fireflyiii/core/tags
  version: 'version-6.1.10'
  # https://hub.docker.com/r/fireflyiii/data-importer/tags
  importer_version: 'version-1.3.0'
  # https://hub.docker.com/_/mariadb/tags
  db_version: '10.9.6'

  data_dir: /srv/firefly-data

proxy_vhosts:
  firefly_importer:
    domain: firefly-import.local.pws
    port: {{ static.proxy_ports.firefly_imp_http }}
    ssl: internal
    ssl_name: local
