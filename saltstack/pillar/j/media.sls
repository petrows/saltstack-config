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
    jmama:
      data_dir: /srv/rslsync-data-jmama
      user: master
      port: {{ static.proxy_ports.rslsync_jmama }}

proxy_vhosts:
  rslsync_jmama:
    domain: rslsync-jmama.j.pws
    port: {{ static.proxy_ports.rslsync_jmama }}
    ssl: internal
    ssl_name: j_pws
