samba:
  shares:
    media:
      path: /srv/test-share-ro
      comment: Test share R/O
    media-rw-all:
      path: /srv/test-share-rw
      comment: Test share R/W
      rw: True
    media-rw-locked:
      path: /srv/test-share-rw
      comment: Test share only for special user
      rw: True
      user: share-root
    share:
      path: /srv/test-share-pub
      comment: Test share public R/W
      rw: True
      guest: True
