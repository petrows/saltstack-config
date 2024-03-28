base:
  '*':
    - default
# Password management
    - secrets-default
{% if salt['pillar.file_exists']('secrets.sls') %}
    - secrets
{% endif %}

# Load grains-based info
  'G@oscodename:bullseye':
    - match: compound
    - grains.debian-11
  'G@oscodename:focal':
    - match: compound
    - grains.ubuntu-20
  'G@oscodename:jammy':
    - match: compound
    - grains.ubuntu-22

# All PWS servers should have at least advanced config for root
  '*.pws or *.ows or *.dev':
    - match: compound
    - users.root
    - users.salt
# Mount /tmp into RAM
    - common.tmp-ramdisk
# Generic server role
    - common.server
# Common scripts
    - common.scripts

# All dev servers should have virtual user config
  '*.dev':
    - users.vagrant
    - common.server-dev

# Config by-network
  '10.80.0.0/24':
    - match: ipcidr
    - grains.network-lan
  '10.80.1.0/24':
    - match: ipcidr
    - grains.network-dmz
  '10.80.5.0/24':
    - match: ipcidr
    - grains.network-dmz
  '10.80.6.0/24':
    - match: ipcidr
    - grains.network-smarthome
  # Julia
  '10.82.0.0/16':
    - match: ipcidr
    - grains.network-dmz
    - grains.network-dmz-julia

# Config by-type
# CT machines
  'G@virtual:container':
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
    - grains.host-hdd
    - pws.powerline-gitstatus

  'pve.pws':
    - pws.pve
    # FS honeypots
    - common.integrity-pve

  'octoprint.pws':
    - pws.octoprint

  {# 'pve.ows':
    - ows.pve

  'office.ows':
    - users.master
    - ows.office #}

  'system.*':
    - pws.system
    - users.master
    - services.salt-master
    - services.cmk-server
    - services.graylog
    - services.metrics
    - services.adguard
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
    - common.dante
{% if salt['pillar.file_exists']('pws/nexum.sls') %}
    - pws.nexum
{% endif %}

  'web-vm.*':
    - pws.web-vm
    - users.www
    - users.www-data
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

  'web-vm.dev':
    - pws.web-vm-dev
    - grains.network-dmz

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

  'home.pws':
    - services.openhab-home

  # Banking machine
  'bank.*':
    - pws.bank
    - users.master
    - services.firefly
  'bank.dev':
    - services.firefly-dev
  'bank.pws':
    - services.firefly-prod

  #'home.ows':
  #  - services.openhab-office

  'media.pws or media.dev':
    - match: compound
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

# Test k8s machines
  'k8s-*.pws':
    - services.k8s

# External backup system
  'backup-ext.pws':
    - grains.host-hdd
    - users.master

# External VDS
  'ru.vds.*':
    - pws.ru-vds
# External VDS
  'ua.vds.*':
    - pws.ua-vds
# External VDS
  'eu.vds.*':
    - common.no-torrent
    - pws.eu-vds
# All VDS defaults
  '*.vds.pws':
    - grains.network-dmz
    - grains.network-external
# Test machine
  'ru.vds.dev':
    - common.no-torrent
    - grains.network-dmz

# Local PC config
  'pc-*':
    - common.tmp-ramdisk
    - common.mail-relay
    - common.firefox
    - users.root
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
    - pws.pc-work-private
  'pc-work-nb':
    - pws.pc-work-nb

# Julia hosts
  'pve.j.*':
    - grains.host-hdd
    - users.ssh-pve
    - users.master
    - services.iphone-copy
    - j.pve

  'home.j.*':
    - users.ssh-pve
    - users.master
    - services.openhab
    - services.openhab-julia

  'media.j.*':
    - users.ssh-pve
    - users.master
    - j.media
    - services.rslsync
    - services.samba
    - services.samba-julia
    - services.photoprism
    - services.photoprism-julia

  'vpn.j.*':
    - users.ssh-pve
    - users.master
    - j.vpn
