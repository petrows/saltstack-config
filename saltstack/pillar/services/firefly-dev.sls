{% import_yaml 'static.yaml' as static %}

roles:
  - docker
  - firefly

include:
  - services.nginx

proxy_vhosts:
  adguard:
    domain: firefly.local.pws
    port: {{ static.proxy_ports.firefly_http }}
    ssl: internal
    ssl_name: local
