# Media - Julia

{% import_yaml 'static.yaml' as static %}

check_mk_plugins:
  - mk_docker.py

roles:
  - docker

include:
  - services.nginx

packages_pip3:
  - exifread
  - docker
  - watchdog
