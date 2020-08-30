# We are using docker instance. Bare metal versions cant run with nginx

{% import_yaml 'static.yaml' as static %}

roles:
  - docker
  - nginx
  - cmk-server

check_mk_server:
  version: 1.6.0p16
  data_dir: /srv/cmk-data

proxy_vhosts:
  cmk:
    domain: cmk-dev.local.pws
    port: {{ static.proxy_ports.cmk_http }}
    ssl: internal
    ssl_name: local
