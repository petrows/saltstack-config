samba:
  id: Samba
  name: MEDIA
  workgroup: PETROWS
  shares:
    media:
      path: /srv/media
      comment: Media
      guest: True
    media-rw:
      path: /srv/media
      comment: Media R/W
      user: master
      rw: True
    media-nexum:
      path: /srv/media-private
      comment: Media nexum
      user: share-root
      rw: True
    share:
      path: /srv/share
      comment: Public share
      rw: True
      guest: True
    common:
      path: /srv/storage/common
      comment: Documents
      user: master
      rw: True
    common-old:
      path: /srv/storage-old
      comment: Documents (old)
      user: share-root
    common-tmp:
      path: /srv/storage-tmp
      user: share-root
    julia:
      path: /srv/storage/home/julia
      user: julia
      rw: True
