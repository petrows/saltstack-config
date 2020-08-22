base:

  '*':
    - common

  'pws-*':
    - common.monitoring
    - common.users

  'roles:mounts':
    - match: pillar
    - roles.mounts
  'roles:tmp-ramdisk':
    - match: pillar
    - common.tmp-ramdisk
  'roles:mail-relay':
    - match: pillar
    - common.mail-relay
  'roles:docker':
    - match: pillar
    - common.docker
  'roles:nginx':
    - match: pillar
    - common.nginx
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

  'pws-pve*':
    - pws.pve

  'pws-system*':
    - pws.system

  'pws-backup*':
    - pws.backup

# Local host config
  'petro-pc':
    - common.users
