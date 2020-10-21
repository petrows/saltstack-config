roles:
  - docker
  - plex

plex:
  id: Plex-dev
  # https://hub.docker.com/r/linuxserver/plex/tags
  version: 1.20.3.3437-f1f08d65b-ls119
  data_dir: /srv/plex-data
  mounts: []
