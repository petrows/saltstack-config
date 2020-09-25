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
# Mount /tmp into RAM
    - common.tmp-ramdisk
# Generic server role
    - common.server

# All dev servers should have virtual user config
  '*-dev':
    - users.vagrant
    - common.server-dev

# Separate hosts config
  'pws-pve*':
    - common.server-dedicated
    - pws.pve
    - pws.powerline-gitstatus

  'pws-system*':
    - common.server-public
    - pws.system
    - users.master
    - services.salt-master
    - services.cmk-server
    - services.cmk-server-prod
  'pws-system-dev':
    - pws.system-dev

  'pws-fabian*':
    - users.master

  'pws-octoprint*':
    - common.server-dedicated

  'pws-web-vm*':
    - common.server-dedicated
    - common.server-public
    - common.server-vm
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
    - users.master

  'pws-home*':
    - pws.home
    - users.master
    - services.openhab
  'pws-home':
    - services.openhab-prod

  'pws-media*':
    - users.master
    - services.samba
    - services.plex
    - services.rslsync
    - pws.media
  'pws-media':
    - services.plex-prod
    - services.samba-prod
  'pws-media-dev':
    - services.samba-dev

  'eu.petro.ws':
    - common.server
    - common.server-dedicated
    - common.server-public
    - common.server-external
    - services.nginx
    - users.root
    - pws.eu-petrows

# Local PC config
  'petro-pc':
    - common.tmp-ramdisk
    - common.mail-relay
    - users.root
    - users.petro
    - pws.secrets-default
    - pws.secrets
    - pws.powerline-gitstatus
    - services.rslsync
    - services.rslsync-petro-pc
