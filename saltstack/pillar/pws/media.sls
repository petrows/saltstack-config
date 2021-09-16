{% import_yaml 'static.yaml' as static %}

check_mk_plugins:
  - mk_docker.py

roles:
  - docker
  - nginx

packages:
  - ghostscript
  - hplip

packages_pip3:
  - exifread
  - docker
  - watchdog

rslsync:
  instances:
    petro:
      data_dir: /srv/rslsync-data-petro
      user: master
      port: {{ static.proxy_ports.rslsync_petro }}
    marina:
      data_dir: /srv/rslsync-data-marina
      user: master
      port: {{ static.proxy_ports.rslsync_marina }}

proxy_vhosts:
  rslsync_petro:
    domain: rslsync-petro-dev.local.pws
    port: {{ static.proxy_ports.rslsync_petro }}
    ssl: internal
    ssl_name: local
  rslsync_marina:
    domain: rslsync-marina-dev.local.pws
    port: {{ static.proxy_ports.rslsync_marina }}
    ssl: internal
    ssl_name: local
