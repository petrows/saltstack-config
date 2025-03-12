{% import_yaml 'static.yaml' as static %}

roles:
  - docker
  - zoneminder

include:
  - services.nginx

# https://github.com/ZoneMinder/zoneminder
zoneminder:
  version: 1.36.35
  # Dedicated disk on media.pws
  data_dir: /mnt/zoneminder-data

proxy_vhosts:
  zoneminder:
    domain: zm.media.pws
    port: {{ static.proxy_ports.zoneminder_http }}
    ssl: internal
    ssl_name: media
