crashplan:
  mounts:
    - /srv/pws-media
    - /srv/pws-data

proxy_vhosts:
  crashplan:
    domain: backup.pws
    ssl: internal
    ssl_name: backup
