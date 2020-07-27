domain: web-vm.pws

check_mk_plugins:
  - nginx_status

packages:
  - cifs-utils

roles:
  - docker
  - nginx
