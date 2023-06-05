# Finance apps

check_mk_plugins:
  - nginx_status.py
  - mk_docker.py

# Allow SSH from PVE
ssh:
  keys:
    root@pve.pws:
      user: root
      enc: ssh-ed25519
      key: AAAAC3NzaC1lZDI1NTE5AAAAILO4R2eYkW2YUGB1VBu5XlNRdNlJwceBDEJrNfRtKz/8
