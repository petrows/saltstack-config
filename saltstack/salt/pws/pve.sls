# This option is required for nested CT from Proxmox 6.3-3
# https://forum.proxmox.com/threads/docker-in-lxc-l%C3%A4uft-nicht-mehr.83651/
net.ipv4.ip_forward:
  sysctl.present:
    - value: 1

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

# Disabled due to bug in Salt: https://github.com/saltstack/salt/issues/54075

# Special configs for VM's
# {% for cfg_vm_id, cfg_vm_data in salt.pillar.get('pve_vms_config', {}).items() %}
# {% for cfg_vm_value in cfg_vm_data %}
# 'pve-cfg-{{ cfg_vm_id }}-{{ cfg_vm_value }}':
#   file.replace:
#     - name: /etc/pve/lxc/{{ cfg_vm_id }}.conf
#     - pattern: '{{ cfg_vm_value | regex_escape }}'
#     - repl: '{{ cfg_vm_value }}'
#     - append_if_not_found: True
# {% endfor %}
# {% endfor %}

# Load overlay module to allow run docker in CT
pve-modules:
  kmod.present:
    - persist: True
    - mods:
      - overlay

# Backup system
pve-backup-deps:
  pkg.installed:
    - pkgs:
      - python3
      - rsnapshot
      - hdparm

pve-udev:
  file.managed:
    - name: /etc/udev/rules.d/10-local.rules
    - source: salt://files/pws-pve/udev-10-local.rules

pve-backup.service:
  file.managed:
    - name: /etc/systemd/system/pve-backup.service
    - source: salt://files/pws-pve/pve-backup.service
  service.enabled:
    - enable: True

pve-backup.timer:
  file.managed:
    - name: /etc/systemd/system/pve-backup.timer
    - source: salt://files/pws-pve/pve-backup.timer
  service.running:
    - enable: True

pve-backup-code:
  file.recurse:
    - name: /opt/backup
    - source: salt://files/pws-pve/backup
    - file_mode: keep
