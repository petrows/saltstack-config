{% import_yaml 'static.yaml' as static %}

roles:
  - docker
  - privatebin

include:
  - services.nginx

privatebin:
  # https://hub.docker.com/r/privatebin/nginx-fpm-alpine/
  version: 1.7.3
  data_dir: /srv/pw-data

proxy_vhosts:
  privatebin:
    domain: pw.petro.ws
    port: {{ static.proxy_ports.privatebin_http }}
    ssl: external
