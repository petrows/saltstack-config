domain: web-vm.pws

check_mk_plugins:
  - nginx_status

packages:
  - nfs-common

roles:
  - docker
  - nginx
