roles:
  - mounts

packages:
  - mount.cifs

mounts:
  nextcloud-data:
    name: /opt/nextcloud-data
    device: pve.pws:/srv/hdd2/web/nextcloud
    type: nfs
    opts: defaults
  wiki-data:
    name: /opt/wiki-data
    device: pve.pws:/srv/hdd2/web/wiki
    type: nfs
    opts: defaults

# Force generate new dhparm keys for Nginx (required for external servers)
nginx:
  dhparam: True
