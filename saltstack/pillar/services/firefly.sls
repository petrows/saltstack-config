{% import_yaml 'static.yaml' as static %}

roles:
  - docker
  - firefly

firefly:
  id: Firefly-dev

  # https://hub.docker.com/r/fireflyiii/core/tags
  version: 'version-6.0.11'
  # https://hub.docker.com/r/fireflyiii/data-importer/tags
  importer_version: 'version-1.2.2'
  # https://hub.docker.com/_/mariadb/tags
  db_version: '10.9.6'

  data_dir: /srv/firefly-data
