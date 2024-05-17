samba:
  id: Samba
  name: MEDIA
  workgroup: PETROWS
  shares:
    media:
      path: /mnt/pws-media/media
      comment: Media
      guest: True
    media-rw:
      path: /mnt/pws-media/media
      comment: Media R/W
      user: share-root master
      rw: True
    media-nexum:
      path: /mnt/pws-media/private
      comment: Media nexum
      user: share-root
      rw: True
    share:
      path: /mnt/pws-data/share
      comment: Public share
      rw: True
      guest: True
    common:
      path: /mnt/pws-data/storage/common
      comment: Documents
      user: share-root master julia
    common-old:
      path: /mnt/pws-data/storage-old
      comment: Documents (old)
      user: share-root julia
    # common-tmp:
    #   path: /mnt/pws-data/tmp
    #   user: share-root
    julia:
      path: /mnt/pws-data/storage/home/julia
      user: julia
      rw: True
