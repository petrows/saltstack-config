{% import_yaml 'static.yaml' as static %}

roles:
  - docker
  - photoprism

include:
  - services.nginx

photoprism:
  id: Photoprism-dev
  # https://hub.docker.com/r/photoprism/photoprism/tags
  version: '250228'
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
  creds: photoprism

  mariadb:
    id: Photoprism-db-dev
    version: 10.11.2
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

