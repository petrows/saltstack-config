base:

  # Grains
  'os:Ubuntu':
    - match: grain
    - grains.ubuntu

  'os:Debian':
    - match: grain
    - grains.debian

  '*':
    - common
    - common.users
    - common.mounts
    - common.mount-folders
    - common.scripts
    - roles.docker-compose-macro

  # HW based
  'roles:server-vm':
    - match: pillar
    - roles.server-vm

  'roles:tuxedo':
    - match: pillar
    - roles.tuxedo

  # Roles (optional features)
  'roles:server':
    - match: pillar
    - roles.server
  'roles:monitoring':
    - match: pillar
    - roles.monitoring
  'roles:mail-relay':
    - match: pillar
    - roles.mail-relay
  'roles:docker':
    - match: pillar
    - roles.docker
  'roles:nginx':
    - match: pillar
    - roles.nginx
  'roles:php-fpm':
    - match: pillar
    - roles.php-fpm
  'roles:jenkins-node':
    - match: pillar
    - roles.jenkins-node
  'roles:unattended-upgrades':
    - match: pillar
    - roles.unattended-upgrades
  'roles:wireguard-server':
    - match: pillar
    - roles.wireguard-server
  'roles:awg-server':
    - match: pillar
    - roles.awg-server
  'roles:integrity_client':
    - match: pillar
    - roles.integrity_client
  'roles:firefox':
    - match: pillar
    - roles.firefox
  'roles:dante':
    - match: pillar
    - roles.dante
  'roles:iphone-copy':
    - match: pillar
    - roles.iphone-copy
  'roles:proxmox':
    - match: pillar
    - roles.proxmox
  'roles:scan':
    - match: pillar
    - roles.scan
  'roles:node-exporter':
    - match: pillar
    - roles.node-exporter
  'roles:vmagent':
    - match: pillar
    - roles.vmagent
  'roles:vector':
    - match: pillar
    - roles.vector
  'roles:dns-dot':
    - match: pillar
    - roles.dns-dot
  'roles:no-torrent':
    - match: pillar
    - roles.no-torrent

  # Services
  'roles:salt-master':
    - match: pillar
    - services.salt-master
  'roles:salt-minion':
    - match: pillar
    - services.salt-minion
  'roles:openhab':
    - match: pillar
    - services.openhab
  'roles:wiki':
    - match: pillar
    - services.wiki
  'roles:nextcloud':
    - match: pillar
    - services.nextcloud
  'roles:jenkins':
    - match: pillar
    - services.jenkins
  'roles:gitlab':
    - match: pillar
    - services.gitlab
  'roles:cmk-server':
    - match: pillar
    - services.cmk-server
  'roles:samba':
    - match: pillar
    - services.samba
  'roles:plex':
    - match: pillar
    - services.plex
  'roles:rslsync':
    - match: pillar
    - services.rslsync
  'roles:graylog':
    - match: pillar
    - services.graylog
  'roles:crashplan':
    - match: pillar
    - services.crashplan
  'roles:photoprism':
    - match: pillar
    - services.photoprism
  'roles:metrics':
    - match: pillar
    - services.metrics
  'roles:adguard':
    - match: pillar
    - services.adguard
  'roles:php-docker':
    - match: pillar
    - services.php-docker
  'roles:firefly':
    - match: pillar
    - services.firefly
  'roles:paperless':
    - match: pillar
    - services.paperless
  'roles:k8s':
    - match: pillar
    - services.k8s
  'roles:k8s-node':
    - match: pillar
    - services.k8s-node
  'roles:k8s-cp':
    - match: pillar
    - services.k8s-cp
  'roles:octoprint':
    - match: pillar
    - services.octoprint
  'roles:privatebin':
    - match: pillar
    - services.privatebin
  'roles:trss':
    - match: pillar
    - services.trss
  'roles:jvpn':
    - match: pillar
    - services.jvpn
  'roles:zoneminder':
    - match: pillar
    - services.zoneminder
  'roles:file-storage':
    - match: pillar
    - services.file-storage
  'roles:photosync-sftp':
    - match: pillar
    - services.photosync-sftp

  # Hosts configs
  'pve.pws':
    - pws.pve

  'octoprint.pws':
    - pws.octoprint

  'system.*':
    - pws.system

  'backup.*':
    - pws.backup

  'home.*':
    - pws.home

  'media.pws or media.dev':
    - match: compound
    - pws.media

  'nexum.*':
    - pws.nexum

  'vpn-gw.pws':
    - pws.vpn-gw

  'cz.vds.*':
    - pws.cz-vds

# Remote host config

  'backup-ext.*':
    - pws.backup-ext

# Local host config
  'pc-*':
    - common.users
    - services.salt-repo
    - pws.local-pc

  'pc-home':
    - pws.pc-home

  'pc-work-nb':
    - pws.local-laptop
    - pws.pc-work-private

# Julia
  'pve.j.pws':
    - j.pve

# W
  'pve.w.pws':
    - w.pve
# M
  'pve.m.pws':
    - m.pve
