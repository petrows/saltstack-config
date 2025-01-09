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
  'G@oscodename:noble':
    - match: compound
    - grains.ubuntu-24

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
    - grains.vagrant
    - users.vagrant
    - common.server-dev

# Config by-network
  '10.80.0.0/24':
    - match: ipcidr
    - grains.network-lan
    - common.salt-minion
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
    - grains.region-ru
    - grains.network-dmz
    - grains.network-dmz-julia
  # m
  '10.87.0.0/16':
    - match: ipcidr
    - grains.network-dmz
    - grains.network-dmz-m
  # w
  '10.88.0.0/16':
    - match: ipcidr
    - grains.network-dmz
    - grains.network-dmz-w

  # Special network conig
  # Mobile devices
  '*-nb':
    - grains.network-laptop

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
# RPI machines
  'G@productname:Raspberry*':
    - match: compound
    - grains.rpi

# Separate hosts config
  'pve.*':
    - grains.host-hdd
    - grains.proxmox
    - pws.powerline-gitstatus
    - users.ssh-pve

  'pve.pws':
    - pws.pve
    # Metrics service
    - services.vmagent
    - services.vmagent-pve
    # FS honeypots
    - common.integrity-pve

  'octoprint.*':
    - users.ssh-pve
    - users.octoprint
    - services.octoprint

  'octoprint.pws':
    - pws.octoprint
    - services.octoprint-prod

  'system.*':
    - pws.system
    - users.master
    - services.salt-master
    - services.cmk-server
  #  - services.graylog
  #  - services.metrics
    - services.adguard
  'system.pws':
    - services.salt-master-prod
    - services.cmk-server-prod
  #  - services.graylog-prod
  #  - services.metrics-prod
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
    - users.ssh-pve
    - services.wiki
    - services.nextcloud
    - services.gitlab
    - services.privatebin
    - services.trss

  'web-vm.pws':
    - services.wiki-prod
    - services.nextcloud-prod
    - services.gitlab-prod
    - services.trss-prod
    - pws.web-vm-prod

  'web-vm.dev':
    - pws.web-vm-dev
    - grains.network-dmz

  'backup.*':
    - services.crashplan
    - services.crashplan-prod

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
    - users.ssh-pve
    - services.firefly
  'bank.dev':
    - services.firefly-dev
  'bank.pws':
    - services.firefly-prod

  'vpn-gw.pws':
    - pws.vpn-gw

  #'home.ows':
  #  - services.openhab-office

  'media.pws or media.dev':
    - match: compound
    - users.master
    - common.scan
    - services.samba
    - services.rslsync
    - services.photoprism
    - services.paperless
    - pws.media
  'media.pws':
    - pws.media-prod
    - services.samba-prod
    - services.photoprism-prod
    - services.paperless-prod
  'media.dev':
    - services.samba-dev

  'metrics.dev':
    - services.metrics

# K8S Nodes
  'k8s-*.pws':
    - services.k8s
    - services.k8s-node
  'k8s-cp-*.pws':
    - services.k8s-cp
  'k8s-node-*.pws':
    - services.k8s-worker

# External backup system
  'backup-ext.pws':
    - grains.host-hdd
    - users.master

# All VDS defaults
  '*.vds.pws':
    - grains.network-dmz
    - grains.network-external
# External VDS
  'ru.vds.*':
    - pws.ru-vds
# External VDS
  'ua.vds.*':
    - pws.ua-vds
# External VDS
  'cz.vds.*':
    - grains.region-cz
    - common.no-torrent
    - pws.cz-vds
# Test machine
  'ru.vds.dev':
    - common.no-torrent
    - grains.network-dmz

# Local PC config
  'pc-*':
    - common.tmp-ramdisk
    - common.mail-relay
    - common.firefox
    - common.scripts
    - common.scan
    - users.root
    - pws.powerline-gitstatus
    - services.rslsync
    - services.k8s
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
  #'pve.t.*':
    - grains.host-hdd
    - users.ssh-pve
    - users.master
    - services.iphone-copy
    - services.vmagent
    - services.vmagent-pve-j
    - j.pve

  'media.j.*':
    - users.master
    - services.rslsync
    - j.media

  'home.j.*':
    - users.ssh-pve
    - users.master
    - services.openhab
    - services.openhab-julia

  'vpn.j.*':
    - users.ssh-pve
    - users.master
    - services.vmagent
    - services.vmagent-passive
    - j.vpn

  'vpn-gw.j.*':
    - users.ssh-pve
    - j.vpn-gw

  'web.j.*':
    - users.ssh-pve
    - users.master
    - j.web

# W hosts
  'pve.w.*':
    - grains.host-hdd
    - services.vmagent
    - services.vmagent-pve-w
    - w.pve

# M hosts
  'pve.m.*':
    - grains.host-hdd
    - services.vmagent
    - services.vmagent-pve-m
    - m.pve
