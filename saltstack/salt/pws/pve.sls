
# Common folders
pve-export-web:
  file.directory:
    - name:  /srv/hdd2/web/nextcloud-data
    - user:  {{ salt.pillar.get('static:uids:www-data') }}
    - group:  {{ salt.pillar.get('static:uids:www-data') }}
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

# Special configs for VM's
{% for cfg_vm_id, cfg_vm_data in salt.pillar.get('pve_vms_config', {}).items() %}
{% for cfg_vm_value in cfg_vm_data %}
'pve-cfg-{{ cfg_vm_id }}-{{ cfg_vm_value }}':
  file.replace:
    - name: /etc/pve/lxc/{{ cfg_vm_id }}.conf
    - pattern: '{{ cfg_vm_value | regex_escape }}'
    - repl: '{{ cfg_vm_value }}'
    - append_if_not_found: True
{% endfor %}
{% endfor %}
