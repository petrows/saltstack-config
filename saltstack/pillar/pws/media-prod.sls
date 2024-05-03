{% import_yaml 'static.yaml' as static %}

proxy_vhosts:
  rslsync_petro:
    domain: rslsync-petro.media.pws
    ssl: internal
    ssl_name: media
  rslsync_julia:
    domain: rslsync-julia.media.pws
    ssl: internal
    ssl_name: media

mount-folders:
  photoprism-photos-archive:
    device: /srv/storage/common/photo/photos
    name: /srv/photoprism-data/originals/photos
    user: {{ static.uids.master }}
    group: {{ static.uids.master }}
  photoprism-photos-sync-petro:
    device: /srv/storage/home/petro/mobile-photos/Camera
    name: /srv/photoprism-data/originals/mobile-petro
    user: {{ static.uids.master }}
    group: {{ static.uids.master }}
