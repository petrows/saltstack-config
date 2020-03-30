base:
  '*':
    - default

# All PWS servers should have at least advanced config for root
  'pws-*':
    - pws.user-root

# All dev servers should have virtual user config
  '*-dev':
    - pws.user-vagrant
    - pws.powerline-legacy

# Separate hosts config
  'pws-system*':
    - pws.system
    - pws.user-master
  'pws-system-dev':
    - pws.system-dev
  'pws-web-vm*':
    - pws.web-vm
    - pws.user-www
    