roles:
  - docker
  - samba

samba:
  id: Samba-dev
  version_base: alpine:3.12.0
  data_dir: /srv/samba-data
  shares: {}
