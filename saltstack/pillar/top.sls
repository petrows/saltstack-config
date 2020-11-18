base:
  '*':
    - default
# Password management
    - pws.secrets-default
{% if salt['pillar.file_exists']('pws/secrets.sls') %}
    - pws.secrets
{% endif %}

# Load grains-based info
  'G@oscodename:buster':
    - match: compound
    - grains.debian-10

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
    - services.graylog
  'pws-system':
    - services.salt-master-prod
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

  'pws-build-linux*':
    - pws.build-linux
    - users.master
    - users.jenkins
    - services.docker
    - services.jenkins-node

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

  'eu.petro.ws*':
    - common.server
    - common.server-dedicated
    - common.server-public
    - common.server-external
    - services.nginx
    - services.php-fpm
    - services.jenkins-node
    - users.root
    - users.www_eu
    - pws.eu-petrows
  'eu.petro.ws-dev':
    - pws.eu-petrows-dev

# Local PC config
  'pc-*':
    - common.tmp-ramdisk
    - common.mail-relay
    - users.root
    - pws.secrets-default
    - pws.secrets
    - pws.powerline-gitstatus
    - services.rslsync
    - pws.pc

  'pc-home':
    - users.petro
    - pws.pc-home

# Work PC config
  'pc-work':
    - users.pgolovachev
    - pws.pc-work
  'pc-work-nb':
    - users.pgolovachev
    - pws.pc-work-nb
