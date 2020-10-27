roles:
  - docker
  - plex

plex:
  id: Plex-dev
  # https://hub.docker.com/r/linuxserver/plex/tags
  version: 1.20.3.3483-211702a9f-ls120
  data_dir: /srv/plex-data
  mounts: []
