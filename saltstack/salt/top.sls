base:

  '*':
    - common
    - common.users
    - common.mounts
    - common.mount-folders

  # Install python2 pip for some requiremts
  'check_mk_plugins:mk_docker.py':
    - match: pillar
    - common.python2-pip

  # Roles (optional features)
  'roles:server':
    - match: pillar
    - roles.server
  'roles:monitoring':
    - match: pillar
    - roles.monitoring
  'roles:tmp-ramdisk':
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

  # Services
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

  # Hosts configs
  'pws-pve*':
    - pws.pve

  'pws-system*':
    - pws.system

  'pws-backup*':
    - pws.backup

  'pws-home*':
    - pws.home

  'pws-media*':
    - pws.media

# Local host config
  'petro-pc':
    - common.users
