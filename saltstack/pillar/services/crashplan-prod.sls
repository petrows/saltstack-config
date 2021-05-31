crashplan:
  mounts:
    - /srv/hdd2
    - /srv/pws-data

proxy_vhosts:
  crashplan:
    domain: backup.pws
    ssl: internal
    ssl_name: backup
