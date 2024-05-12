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
  - tesseract-ocr
  - tesseract-ocr-rus
  - tesseract-ocr-deu
  - tesseract-ocr-eng
  - ocrmypdf
  - pdftk-java

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
