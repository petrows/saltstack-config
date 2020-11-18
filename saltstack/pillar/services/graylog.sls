{% import_yaml 'static.yaml' as static %}

roles:
  - docker
  - nginx
  - graylog

graylog:
  # Graylog: https://hub.docker.com/r/graylog/graylog/
  version: 3.3
  # Elasticsearch: https://www.elastic.co/guide/en/elasticsearch/reference/6.x/docker.html
  version_elasticsearch: 6.8.10
  data_dir: /srv/graylog-data

proxy_vhosts:
  graylog:
    domain: graylog-dev.local.pws
    port: {{ static.proxy_ports.graylog_http }}
    ssl: internal
    ssl_name: local
