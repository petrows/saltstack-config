base:
  '*':
    - default

# All PWS servers should have at least advanced config for root
  'pws-*':
    - pws.user-root
# Password management
    - pws.secrets-default
    - pws.secrets
# Redirect local email to mine
    - pws.mail-redirect
# Mount /tmp into RAM
    - pws.role-tmpramdisk

# All dev servers should have virtual user config
  '*-dev':
    - pws.user-vagrant

# Separate hosts config
  'pws-pve*':
    - pws.pve
    - pws.powerline-gitstatus
  'pws-system*':
    - pws.system
    - pws.user-master
  'pws-system-dev':
    - pws.system-dev
  'pws-web-vm*':
    - pws.web-vm
    - pws.user-www
  'pws-backup*':
    - pws.user-master

# Local PC config
  'petro-pc':
    - pws.user-root
    - pws.user-petro
    - pws.secrets-default
    - pws.secrets
    - pws.mail-redirect
    - pws.role-tmpramdisk
