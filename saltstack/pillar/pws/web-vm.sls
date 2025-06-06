domain: web-vm.pws

check_mk_plugins:
  - nginx_status.py
  - mk_docker.py

packages:
  - nfs-common

roles:
  - docker

include:
  - services.nginx

swap_size_mb: {{ 4 * 1024 }}
