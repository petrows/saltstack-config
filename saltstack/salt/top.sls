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

  # Hosts configs
  'pve.*':
    - pws.pve

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

  'rpi.office.*':
    - office.rpi

# Local host config
  'pc-*':
    - common.users
    - pws.local-pc

  'pc-home':
    - pws.pc-home
