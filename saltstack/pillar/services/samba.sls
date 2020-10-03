{% import_yaml 'static.yaml' as static %}

roles:
  - docker
  - samba

samba:
  id: Samba-dev
  version_base: alpine:3.12.0
  data_dir: /srv/samba-data
  user: master
  name: MEDIA-DEV
  workgroup: TESTWG
  shares: {}
  smb_users:
    share-root: {{ static.uids.share_root }}
    share: {{ static.uids.share }}
