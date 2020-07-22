roles:
  - mounts

mounts:
  srv-web:
    name: /srv/web
    device: pve.pws:/srv/hdd2/web
    type: nfs
    opts: defaults
