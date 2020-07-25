base:
  '*':
    - default
# Password management
    - pws.secrets-default
{% if salt['pillar.file_exists']('pws/secrets.sls') %}
    - pws.secrets
{% endif %}
# All PWS servers should have at least advanced config for root
  'pws-*':
    - users.root
# Redirect local email to mine
    - pws.mail-redirect
# Mount /tmp into RAM
    - common.tmp-ramdisk

# All dev servers should have virtual user config
  '*-dev':
    - users.vagrant

# Separate hosts config
  'pws-pve*':
    - pws.pve
    - pws.powerline-gitstatus
  'pws-system*':
    - pws.system
    - users.master
  'pws-fabian*':
    - users.master
  'pws-system-dev':
    - pws.system-dev
  'pws-web-vm*':
    - pws.web-vm
    - users.www
    - services.wiki
    - services.nextcloud
  'pws-web-vm':
    - pws.web-vm-prod
  'pws-backup*':
    - users.master
  'pws-home-dev':
    - users.master
    - services.openhab

# Local PC config
  'petro-pc':
    - users.root
    - users.petro
    - pws.secrets-default
    - pws.secrets
    - pws.mail-redirect
    - pws.role-tmpramdisk
    - pws.powerline-gitstatus
