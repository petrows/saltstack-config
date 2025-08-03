{% import_yaml 'static.yaml' as static %}

check_mk_plugins:
  - mk_docker.py

roles:
  - docker

include:
  - services.nginx

packages:
  - ghostscript
  - hplip

packages_pip3:
  - PyPDF2

rslsync:
  instances:
    petro:
      data_dir: /srv/rslsync-data-petro
      user: master
      port: {{ static.proxy_ports.rslsync_petro }}
    julia:
      data_dir: /srv/rslsync-data-julia
      user: master
      port: {{ static.proxy_ports.rslsync_julia }}
    jmama:
      data_dir: /srv/rslsync-data-jmama
      user: master
      port: {{ static.proxy_ports.rslsync_jmama }}

proxy_vhosts:
  rslsync_petro:
    domain: rslsync-petro-dev.local.pws
    port: {{ static.proxy_ports.rslsync_petro }}
    ssl: internal
    ssl_name: local
  rslsync_julia:
    domain: rslsync-julia-dev.local.pws
    port: {{ static.proxy_ports.rslsync_julia }}
    ssl: internal
    ssl_name: local
  rslsync_jmama:
    domain: rslsync-jmama-dev.local.pws
    port: {{ static.proxy_ports.rslsync_jmama }}
    ssl: internal
    ssl_name: local
