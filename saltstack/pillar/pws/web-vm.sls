domain: web-vm.pws

check_mk_plugins:
  - nginx_status
  - mk_logwatch

packages:
  - nfs-common

roles:
  - docker
  - nginx
