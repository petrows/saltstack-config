base:
  '*':
    - common
  'pws-*':
    - common.monitoring
    - common.users
  'roles:tmpramdisk'
    - match: pillar
    - common.tmp-ramdisk
  'roles:nginx':
    - match: pillar
    - common.nginx
  'pws-system*':
    - pws.system
    - common.mail-relay
  