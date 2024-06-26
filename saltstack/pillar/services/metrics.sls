{% import_yaml 'static.yaml' as static %}

roles:
  - docker
  - metrics

include:
  - services.nginx

metrics:
  data_dir: /srv/metrics-data
  # https://hub.docker.com/r/victoriametrics/victoria-metrics
  victoriametrics:
    version: v1.68.0
  # victoriametrics/vmagent
  vmagent:
    version: v1.70.0
  # https://hub.docker.com/r/grafana/grafana
  grafana:
    version: 10.4.2
  # https://hub.docker.com/_/telegraf
  telegraf:
    version: 1.20.3
  # https://hub.docker.com/r/prom/snmp-exporter/
  snmp_exporter:
    version: v0.20.0
  mktxp:
    version: latest # WTF

proxy_vhosts:
  grafana:
    domain: grafana-dev.local.pws
    port: {{ static.proxy_ports.grafana_http }}
    ssl: internal
    ssl_name: local
