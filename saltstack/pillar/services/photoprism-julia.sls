photoprism:
  id: Photoprism-julia
  volumes:
    cache:
      path: /mnt/julia-data/cache/photoprism
    import:
      path: /srv/photoprism-data/import
    originals:
      path: /mnt/julia-data/storage/Фото

  mariadb:
    id: Photoprism-db-julia

proxy_vhosts:
  photoprism:
    domain: photos.j.pws
    ssl: internal
    ssl_name: j_pws
