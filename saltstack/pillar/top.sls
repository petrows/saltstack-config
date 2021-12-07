base:
  '*':
    - default
# Password management
    - secrets-default
{% if salt['pillar.file_exists']('secrets.sls') %}
    - secrets
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
    - users.salt
# Mount /tmp into RAM
    - common.tmp-ramdisk
# Generic server role
    - common.server

# All dev servers should have virtual user config
  '*.dev':
    - users.vagrant
    - common.server-dev

# Config by-network
  '192.168.80.0/24':
    - match: ipcidr
    - grains.network-lan
  '10.80.1.0/24':
    - match: ipcidr
    - grains.network-dmz
  '10.80.5.0/24':
    - match: ipcidr
    - grains.network-dmz

# Config by-type
# CT machines
  'G@virtual:LXC':
    - match: compound
    - grains.host-ct
# VM machines
  'G@virtual:kvm or G@virtual:VMware':
    - match: compound
    - grains.host-vm
# Real machines
  'G@virtual:physical':
    - match: compound
    - grains.host-physical

# Separate hosts config
  'pve.*':
    - pws.pve
    - pws.powerline-gitstatus

  'system.*':
    - pws.system
    - users.master
    - services.salt-master
    - services.cmk-server
    - services.graylog
    - services.metrics
  'system.pws':
    - services.salt-master-prod
    - services.cmk-server-prod
    - services.graylog-prod
    - services.metrics-prod
  'system.dev':
    - pws.system-dev

  'fabian.pws':
    - users.master
{% if salt['pillar.file_exists']('pws/fabian.sls') %}
    - pws.fabian
{% endif %}

  'nexum.pws':
    - users.master
{% if salt['pillar.file_exists']('pws/nexum.sls') %}
    - pws.nexum
{% endif %}

  'web-vm.*':
    - pws.web-vm
    - users.www
    - services.wiki
    - services.nextcloud
    - services.jenkins
    #- services.gitlab

  'web-vm.pws':
    - services.wiki-prod
    - services.nextcloud-prod
    - services.jenkins-prod
    #- services.gitlab-prod
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
    - services.photoprism
    - pws.media
  'media.pws':
    - pws.media-prod
    - services.plex-prod
    - services.samba-prod
    - services.photoprism-prod
  'media.dev':
    - services.samba-dev

  'metrics.dev':
    - services.metrics

  'eu.petro.*':
    - common.server
    - services.nginx
    - services.php-fpm
    - services.jenkins-node
    - users.root
    - users.salt
    - users.www_eu
    - pws.eu-petrows
  'eu.petro.dev':
    - pws.eu-petrows-dev
  'eu.petro.ws':
    - grains.network-dmz

  'rpi.office.*':
    - office.rpi
  'rpi.office.dev':
    - office.rpi-dev
  'rpi.office.pws':
    - grains.network-dmz

# External VDS
  'ru.vds.*':
    - pws.ru-vds
# External VDS
  'ua.vds.*':
    - pws.ua-vds
# All VDS defaults
  '*.vds.pws':
    - grains.network-dmz

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
