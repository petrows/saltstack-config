# Media - Julia

{% import_yaml 'static.yaml' as static %}

check_mk_plugins:
  - mk_docker.py

roles:
  - docker

include:
  - services.nginx

rslsync:
  instances:
    j:
      data_dir: /srv/rslsync-data-j
      user: master
      port: {{ static.proxy_ports.rslsync_julia }}

proxy_vhosts:
  rslsync_j:
    domain: sync.j.pws
    port: {{ static.proxy_ports.rslsync_julia }}
    ssl: internal
    ssl_name: media
