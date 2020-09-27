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
      rw: True
    share:
      path: /srv/share
      comment: Public share
      rw: True
      guest: True
    common:
      path: /srv/storage/common
      comment: Documents
      rw: True
    common-old:
      path: /srv/storage-old
      comment: Documents (old)
      user: share-root
    common-tmp:
      path: /srv/storage-tmp
      user: share-root
    marina:
      path: /srv/storage/home/marina
      comment: Marina private
      rw: True
