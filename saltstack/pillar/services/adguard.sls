{% import_yaml 'static.yaml' as static %}

roles:
  - docker
  - nginx
  - adguard

# https://hub.docker.com/r/adguard/adguardhome
adguard:
  version: v0.106.3
  data_dir: /srv/adguard-data

proxy_vhosts:
  adguard:
    domain: adguard.system.pws
    port: {{ static.proxy_ports.adguard_http }}
    ssl: internal
    ssl_name: system
