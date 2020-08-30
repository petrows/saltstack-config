base:

  '*':
    - common
    - common.users
    - common.mounts
    - common.mount-folders

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

  # Hosts configs
  'pws-pve*':
    - pws.pve

  'pws-system*':
    - pws.system

  'pws-backup*':
    - pws.backup

  'pws-home*':
    - pws.home

# Local host config
  'petro-pc':
    - common.users
