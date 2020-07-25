roles:
  - mounts

mounts:
  srv-web:
    name: /opt/nextcloud-data
    device: pve.pws:/srv/hdd2/web/nextcloud
    type: nfs
    opts: defaults

# Force generate new dhparm keys for Nginx (required for external servers)
nginx:
  dhparam: True
