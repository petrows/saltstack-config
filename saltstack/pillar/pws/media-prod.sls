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
    device: /mnt/pws-data/storage/common/photo/photos
    name: /mnt/photoprism-originals/photos
    user: {{ static.uids.master }}
    group: {{ static.uids.master }}
  photoprism-photos-old:
    device: /mnt/pws-data/storage-old/photo-old/photos/
    name: /mnt/photoprism-originals/photos-old
    user: {{ static.uids.master }}
    group: {{ static.uids.master }}
  photoprism-photos-sync-petro:
    device: /mnt/pws-data/storage/home/petro/mobile-photos/Camera
    name: /mnt/photoprism-originals/mobile-petro
    user: {{ static.uids.master }}
    group: {{ static.uids.master }}
  photoprism-photos-metaview-sync-petro:
    device: /mnt/pws-data/storage/home/petro/mobile-metaview/
    name: /mnt/photoprism-originals/metaview
    user: {{ static.uids.master }}
    group: {{ static.uids.master }}
  photoprism-photos-julia:
    device: /mnt/pws-data/storage/home/julia/Фото/
    name: /mnt/photoprism-originals/photos-julia
    user: {{ static.uids.master }}
    group: {{ static.uids.master }}
