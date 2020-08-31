domain: web-vm.pws

check_mk_plugins:
  - nginx_status
  - mk_logwatch
  - mk_docker.py

packages:
  - nfs-common

roles:
  - docker
  - nginx

swap_size_mb: {{ 4 * 1024 }}
