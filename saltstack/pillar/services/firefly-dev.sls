{% import_yaml 'static.yaml' as static %}

roles:
  - docker
  - firefly

proxy_vhosts:
  firefly:
    domain: firefly.local.pws
    port: {{ static.proxy_ports.firefly_http }}
    ssl: internal
    ssl_name: local
