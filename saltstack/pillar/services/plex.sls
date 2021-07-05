roles:
  - docker
  - plex

plex:
  id: Plex-dev
  # https://hub.docker.com/r/linuxserver/plex/tags
  version: 1.23.3.4707-ebb5fe9f3-ls59
  data_dir: /srv/plex-data
  mounts: []
