roles:
  - docker
  - plex

plex:
  id: Plex-dev
  # https://hub.docker.com/r/linuxserver/plex/tags
  version: amd64-1.24.5
  data_dir: /srv/plex-data
  mounts: []
