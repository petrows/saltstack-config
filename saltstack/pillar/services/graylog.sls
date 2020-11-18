{% import_yaml 'static.yaml' as static %}

roles:
  - docker
  - nginx
  - graylog

graylog:
  version: 3.3
  data_dir: /srv/graylog-data

proxy_vhosts:
  graylog:
    domain: graylog-dev.local.pws
    port: {{ static.proxy_ports.graylog_http }}
    ssl: internal
    ssl_name: local
