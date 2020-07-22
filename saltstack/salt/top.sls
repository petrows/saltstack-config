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
  'roles:docker':
    - match: pillar
    - common.docker
  'roles:nginx':
    - match: pillar
    - common.nginx
  'pws-system*':
    - pws.system
    - common.mail-relay
  'pws-web-vm*':
    - pws.web-vm
    - common.mail-relay
  'pws-backup*':
    - pws.backup
    - common.mail-relay
  'petro-pc':
    - common.users
    - common.mail-relay
