{% import_yaml 'static.yaml' as static %}

roles:
  - docker
  - nginx
  - photoprism

photoprism:
  id: Photoprism-dev
  version: 20211018
  data_dir: /srv/photoprism-data/app
  volumes:
    cache:
      path: /tmp/cache
      mode: rw
    import:
      path: /tmp/import
      mode: ro
    originals:
      path: /tmp/originals
      mode: ro

  mariadb:
    id: Photoprism-db-dev
    version: 10.5.12
    data_dir: /srv/photoprism-data/db

proxy_vhosts:
  photoprism:
    domain: photos-dev.local.pws
    port: {{ static.proxy_ports.photoprism_http }}
    ssl: internal
    ssl_name: local
    custom_config_proxy: |
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

