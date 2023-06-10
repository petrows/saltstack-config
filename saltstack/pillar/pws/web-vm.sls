domain: web-vm.pws

check_mk_plugins:
  - nginx_status.py
  - mk_logwatch.py
  - mk_docker.py

packages:
  - nfs-common

roles:
  - docker

include:
  - services.nginx

swap_size_mb: {{ 4 * 1024 }}

# Allow SSH from PVE
ssh:
  keys:
    root@pve.pws:
      user: root
      enc: ssh-ed25519
      key: AAAAC3NzaC1lZDI1NTE5AAAAILO4R2eYkW2YUGB1VBu5XlNRdNlJwceBDEJrNfRtKz/8
