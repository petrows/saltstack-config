roles:
  - docker
  - plex

plex:
  id: Plex-dev
  # https://hub.docker.com/r/linuxserver/plex/tags
  version: 1.21.0.3711-b509cc236-ls6
  data_dir: /srv/plex-data
  mounts: []
