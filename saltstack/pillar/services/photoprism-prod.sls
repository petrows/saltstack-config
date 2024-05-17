photoprism:
  id: Photoprism
  volumes:
    cache:
      path: /mnt/pws-cache/photoprism/cache
    import:
      path: /srv/photoprism-data/import
    originals:
      path: /srv/photoprism-data/originals

  mariadb:
    id: Photoprism-db

proxy_vhosts:
  photoprism:
    domain: photos.media.pws
    ssl: internal
    ssl_name: media
