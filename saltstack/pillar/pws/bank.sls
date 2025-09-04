# Finance apps

{% import_yaml 'static.yaml' as static %}

check_mk_plugins:
  - nginx_status.py
  - mk_docker.py

# OPen port for internal proxy redirect
firewall:
  ports_open:
    firefly-proxy:
      dst: {{ static.proxy_ports.firefly_http }}
      proto: tcp
