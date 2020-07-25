
# Common folders
system_cmk_rootdir:
  file.directory:
    - name:  /srv/hdd2/web
    - user:  1000
    - group:  1000
    - mode:  755

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
