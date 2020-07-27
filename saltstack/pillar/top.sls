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
    - common.mail-relay
    - pws.system
    - users.master
  'pws-system-dev':
    - pws.system-dev

  'pws-fabian*':
    - common.mail-relay
    - users.master

  'pws-web-vm*':
    - common.mail-relay
    - pws.web-vm
    - users.www
    - services.wiki
    - services.nextcloud

  'pws-web-vm':
    - services.wiki-prod
    - services.nextcloud-prod
    - pws.web-vm-prod

  'pws-backup*':
    - common.mail-relay
    - users.master

  'pws-home-dev':
    - users.master
    - services.openhab

# Local PC config
  'petro-pc':
    - common.tmp-ramdisk
    - common.mail-relay
    - users.root
    - users.petro
    - pws.secrets-default
    - pws.secrets
    - pws.mail-redirect
    - pws.powerline-gitstatus
