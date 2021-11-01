{% import_yaml 'static.yaml' as static %}

roles:
  - docker
  - nginx
  - metrics

metrics:
  data_dir: /srv/metrics-data
  # https://hub.docker.com/r/victoriametrics/victoria-metrics
  victoriametrics:
    version: v1.68.0
  # https://hub.docker.com/r/grafana/grafana
  grafana:
    version: 8.2.2
  # https://hub.docker.com/_/telegraf
  telegraf:
    version: 1.20.3

proxy_vhosts:
  grafana:
    domain: grafana-dev.local.pws
    port: {{ static.proxy_ports.grafana_http }}
    ssl: internal
    ssl_name: local
