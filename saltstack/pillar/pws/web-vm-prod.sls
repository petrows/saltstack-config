roles:
  - mounts

mounts:
  nextcloud-data:
    name: /srv/nextcloud-data/data
    device: pve.pws:/srv/hdd2/web/nextcloud-data
    type: nfs
    opts: defaults

# Force generate new dhparm keys for Nginx (required for external servers)
nginx:
  dhparam: True
