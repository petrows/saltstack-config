{% import_yaml 'static.yaml' as static %}

roles:
  - docker
  - metrics

include:
  - services.nginx

metrics:
  data_dir: /srv/metrics-data
  # https://hub.docker.com/r/victoriametrics/victoria-metrics
  victoria-metrics:
    version: v1.132.0
  # https://hub.docker.com/r/grafana/grafana
  grafana:
    version: 12.3.1

proxy_vhosts:
  victoria-metrics:
    domain: vm.system.pws
    port: {{ static.proxy_ports.victoriametrics_http }}
    ssl: internal
    ssl_name: system
  victoria-logs:
    domain: vl.system.pws
    port: {{ static.proxy_ports.victorialogs_http }}
    ssl: internal
    ssl_name: system
  grafana:
    domain: grafana.system.pws
    port: {{ static.proxy_ports.grafana_http }}
    ssl: internal
    ssl_name: system
