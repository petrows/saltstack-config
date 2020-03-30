base:
  '*':
    - default

# All PWS servers should have at least advanced config for root
  'pws-*':
    - pws.user-root

# All dev servers should have virtual user config
  '*-dev':
    - pws.user-vagrant

# Separate hosts config
  'pws-system*':
    - pws.system
    - pws.user-root
    - pws.user-master
  'pws-system-dev':
    - pws.system-dev
