
# Common folders
pve-export-web:
  file.directory:
    - name:  /srv/hdd2/web/nextcloud-data
    - user:  {{ salt.pillar.get('static:uids:www-data') }}
    - group:  {{ salt.pillar.get('static:uids:www-data') }}
    - mode:  775

# Export NFS folders
pve-exports:
  nfs_export.present:
    - name: /srv/hdd2/web
    - clients:
      - hosts: web-vm.pws
        options:
          - rw
          - async
          - no_subtree_check
          - no_root_squash
