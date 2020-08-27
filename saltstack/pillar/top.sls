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
# Generic server role
    - common.server

# All dev servers should have virtual user config
  '*-dev':
    - users.vagrant

# Separate hosts config
  'pws-pve*':
    - common.server-dedicated
    - pws.pve
    - pws.powerline-gitstatus

  'pws-system*':
    - common.server-dedicated
    - common.server-public
    - common.mail-relay
    - pws.system
    - users.master
  'pws-system-dev':
    - pws.system-dev

  'pws-fabian*':
    - common.mail-relay
    - users.master

  'pws-octoprint*':
    - common.server-dedicated
    - common.mail-relay

  'pws-web-vm*':
    - common.server-dedicated
    - common.server-public
    - common.mail-relay
    - pws.web-vm
    - users.www
    - services.wiki
    - services.nextcloud
    - services.jenkins
    - services.gitlab

  'pws-web-vm':
    - services.wiki-prod
    - services.nextcloud-prod
    - services.jenkins-prod
    - services.gitlab-prod
    - pws.web-vm-prod

  'pws-backup*':
    - common.mail-relay
    - users.master

  'pws-home*':
    - pws.home
  'pws-home':
    - pws.home-prod

  'eu.petro.ws':
    - common.server
    - common.server-dedicated
    - common.server-public
    - common.server-external
    - services.nginx
    - users.root
    - pws.mail-redirect

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
