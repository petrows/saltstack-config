base:

  '*':
    - common
    - common.users
    - common.mounts
    - common.mount-folders
    - roles.docker-compose-macro

  # Network-based
  'network:lan':
    - match: pillar
    - roles.server-lan

  # HW based
  'roles:server-vm':
    - match: pillar
    - roles.server-vm

  # Roles (optional features)
  'roles:server':
    - match: pillar
    - roles.server
  'roles:monitoring':
    - match: pillar
    - roles.monitoring
  'tmp_ramdisk:True':
    - match: pillar
    - roles.tmp-ramdisk
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
  'roles:openvpn-server':
    - match: pillar
    - roles.openvpn-server
  'roles:wireguard-server':
    - match: pillar
    - roles.wireguard-server
  'roles:l2tp-server':
    - match: pillar
    - roles.l2tp-server
  'roles:integrity_client':
    - match: pillar
    - roles.integrity_client
  'roles:firefox':
    - match: pillar
    - roles.firefox
  'roles:dante':
    - match: pillar
    - roles.dante

  # Services
  'roles:salt-master':
    - match: pillar
    - services.salt-master
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

  'media.*':
    - pws.media

  'nexum.*':
    - pws.nexum

  'eu.petro.*':
    - pws.eu-petrows

# Remote host config

  'backup-ext.*':
    - pws.backup-ext

# Office host config

  'office.ows':
    - ows.office

  'pve.ows':
    - ows.pve

# Local host config
  'pc-*':
    - common.users
    - pws.local-pc

  'pc-home':
    - pws.pc-home

  'pc-work-nb':
    - pws.local-laptop
