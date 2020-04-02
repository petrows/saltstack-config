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

# All dev servers should have virtual user config
  '*-dev':
    - pws.user-vagrant
    - pws.powerline-legacy

# Separate hosts config
  'pws-pve*':
    - pws.pve
  'pws-system*':
    - pws.system
    - pws.user-master
    - pws.powerline-legacy
  'pws-system-dev':
    - pws.system-dev
  'pws-web-vm*':
    - pws.web-vm
    - pws.user-www
    - pws.powerline-legacy
  'pws-home*':
    - pws.powerline-legacy
  'pws-fabian*':
    - pws.powerline-legacy
  'pws-octoprint*':
    - pws.powerline-legacy
