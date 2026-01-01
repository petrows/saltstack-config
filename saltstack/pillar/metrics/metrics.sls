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
    retention: 5y
  # https://hub.docker.com/r/grafana/grafana
  grafana:
    version: 12.3.1

proxy_vhosts:
  victoria-metrics:
    domain: vm.h.pws
    port: {{ static.proxy_ports.vm_http }}
    ssl: internal
    ssl_name: system
  victoria-metrics-insert:
    # Special domain: another zone (must be defined in all DMZ local networks)
    domain: vm-insert.lan
    port: {{ static.proxy_ports.vm_http }}
    # Port to use for HTTPS connections to VictoriaMetrics-insert, i.e.
    # https://vm-insert.lan:5959/ -> vm:/api/v1/write
    port_https: 5959
    proxy_dst: /api/v1/write
    ssl: internal
    ssl_name: system
  victoria-logs:
    domain: vl.h.pws
    port: {{ static.proxy_ports.vl_http }}
    ssl: internal
    ssl_name: system
  grafana:
    domain: grafana.h.pws
    port: {{ static.proxy_ports.grafana_http }}
    ssl: internal
    ssl_name: system
