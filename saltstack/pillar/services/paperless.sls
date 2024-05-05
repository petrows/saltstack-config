{% import_yaml 'static.yaml' as static %}

roles:
  - docker
  - paperless

include:
  - services.nginx

paperless:
  id: Paperless-dev
  # https://github.com/paperless-ngx/paperless-ngx/pkgs/container/paperless-ngx/versions?filters%5Bversion_type%5D=tagged
  version: 2.7.2
  version_db: 16.2
  version_redis: 7.2.4
  data_dir: /srv/paperless-data
  dirs:
    - /srv/paperless-data/app/consume
    - /srv/paperless-data/app/data
    - /srv/paperless-data/app/media

proxy_vhosts:
  paperless:
    domain: docs-dev.local.pws
    port: {{ static.proxy_ports.paperless_http }}
    ssl: internal
    ssl_name: local
    # Disable Referrer-Policy header, as it breaks Django
    # See: https://github.com/paperless-ngx/paperless-ngx/discussions/5684
    enable_ref: True
