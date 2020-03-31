base:
  '*':
    - common
  'pws-*':
    - common.monitoring
    - common.users
  'roles:nginx':
    - match: pillar
    - common.nginx
  'pws-system*':
    - pws.system
    - common.mail-relay
  