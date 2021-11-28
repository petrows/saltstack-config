# This option is required for nested CT from Proxmox 6.3-3
# https://forum.proxmox.com/threads/docker-in-lxc-l%C3%A4uft-nicht-mehr.83651/
net.ipv4.ip_forward:
  sysctl.present:
    - value: 1

# Network config
pve-net-deps:
  kmod.present:
    - persist: True
    - mods:
      - 8021q
  file.managed:
    - name: /etc/network/interfaces
    - source: salt://files/pws-pve/interfaces

/etc/resolv.conf:
  file.managed:
    - source: salt://files/pws-pve/resolv.conf

# Disabled due to bug in Salt: https://github.com/saltstack/salt/issues/54075

# Special configs for VM's
# {% for cfg_vm_id, cfg_vm_data in salt['pillar.get']('pve_vms_config', {}).items() %}
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

systemd-timesyncd.service:
  service.masked: []

pve-ntp-packages:
  pkg.installed:
    - pkgs:
      - ntp

ntp.service:
  service.running:
    - enable: True
    - require:
      - pkg: pve-ntp-packages

# Wireguard for LXC

pve-backports:
  pkgrepo.managed:
    - humanname: {{ grains.oscodename }}-backports
    - name: deb http://deb.debian.org/debian {{ grains.oscodename }}-backports main
    - file: /etc/apt/sources.list.d/backports.list

pve-wireguard-pkg:
  pkg.installed:
    - pkgs:
      - libmnl-dev
      - libelf-dev
      - pve-headers
      - build-essential
      - pkg-config
      - wireguard-dkms
    - require:
      - pkgrepo: pve-backports

pve-wireguard-kmod:
  kmod.present:
    - mods:
      - wireguard
    - require:
      - pkg: pve-wireguard-pkg

# Key removed
# AAAAB3NzaC1yc2EAAAADAQABAAABAQDiP0FsRR4i76hcs8gf9KXYQcBx2BRnsEaO8qvtqPGZBrQkks8LgmyRzp7GkKWNWmnR+S4YkBESp345E203OPGeFs7PiOH2YiHJZUbxExlvKhMS65OAoXk7e1z832nOWz4REdLbC7t0j16TIAosUV0vdXe83Ri2r5IERB67pPSSTYIsue7undgz9r/71siIWWy3CIS0ZyLcgwQ1cXvCOVOv1dT/5edzXywUwuhU3fqbQIsNVC3i5X4f3ITd+hgT7e6ktE5ELhCz3dR4X/wfELqRJEhHOZ2HrJcAnHG6GvV2FIlbXoROkZQkffPkQ6a8MFJ6EqhNlRlMUMcGQn/MqVcX
