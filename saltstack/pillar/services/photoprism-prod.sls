photoprism:
  id: Photoprism
  volumes:
    import: /srv/photoprism-data/import
    originals: /srv/photoprism-data/originals

  mariadb:
    id: Photoprism-db-dev
    version: 10.5.12
    data_dir: /srv/photoprism-data/db

proxy_vhosts:
  photoprism:
    domain: photos.media.pws
    ssl: internal
    ssl_name: media
