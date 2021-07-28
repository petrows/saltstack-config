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
  'G@oscodename:focal':
    - match: compound
    - grains.ubuntu-20

# All PWS servers should have at least advanced config for root
  '*.pws or *.dev':
    - match: compound
    - users.root
# Mount /tmp into RAM
    - common.tmp-ramdisk
# Generic server role
    - common.server

# All dev servers should have virtual user config
  '*.dev':
    - users.vagrant
    - common.server-dev

# Separate hosts config
  'pve.*':
    - common.server-dedicated
    - pws.pve
    - pws.powerline-gitstatus

  'system.*':
    - common.server-public
    - pws.system
    - users.master
    - services.salt-master
    - services.cmk-server
    - services.graylog
  'system.pws':
    - services.salt-master-prod
    - services.cmk-server-prod
    - services.graylog-prod
  'system.dev':
    - pws.system-dev

  'fabian.pws':
    - users.master

  'octoprint.pws':
    - common.server-dedicated

  'web-vm.*':
    - common.server-dedicated
    - common.server-public
    - common.server-vm
    - pws.web-vm
    - users.www
    - services.wiki
    - services.nextcloud
    - services.jenkins
    - services.gitlab

  'web-vm.pws':
    - services.wiki-prod
    - services.nextcloud-prod
    - services.jenkins-prod
    - services.gitlab-prod
    - pws.web-vm-prod

  'backup.*':
    - services.crashplan
    - services.crashplan-prod

  'build-linux.*':
    - pws.build-linux
    - users.master
    - users.jenkins
    - services.docker
    - services.jenkins-node

  'home.*':
    - pws.home
    - users.master
    - services.openhab
    - services.openhab-prod

  'media.*':
    - users.master
    - services.samba
    - services.plex
    - services.rslsync
    - pws.media
  'media.pws':
    - pws.media-prod
    - services.plex-prod
    - services.samba-prod
  'media.dev':
    - services.samba-dev

  'eu.petro.*':
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
  'eu.petro.dev':
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
  'pc-work*':
    - users.pgolovachev
    - pws.pc-work
  'pc-work-nb':
    - pws.pc-work-nb
