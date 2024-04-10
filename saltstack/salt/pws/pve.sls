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

/etc/network/interfaces:
  file.managed:
    - contents: |
        auto lo
        iface lo inet loopback

        # LAN interface
        iface eth-lan inet manual

        # 2.5Gbe interface
        iface eth-pc inet manual

        # LAN VMs
        auto vmbr0
        iface vmbr0 inet static
            hwaddress 00:1b:21:3a:52:c6
            address 10.80.0.2
            netmask 255.255.255.0
            gateway 10.80.0.1
            bridge_ports eth-lan eth-pc
            bridge_vlan_aware yes
            bridge-vids 2-4094
            bridge_stp off
            bridge_fd 0

        # GUEST
        auto vmbr0.20
        iface vmbr0.20 inet manual

        # DMZ
        auto vmbr0.30
        iface vmbr0.30 inet manual

# Interfaces names
/etc/systemd/network/10-interface-lan.link:
  file.managed:
    - contents: |
        # Main lan uplink
        [Match]
        MACAddress=4c:ed:fb:98:0d:91
        [Link]
        Name=eth-lan

/etc/systemd/network/10-interface-pc.link:
  file.managed:
    - contents: |
        # 2.5Gbe card to PC
        [Match]
        MACAddress=1c:86:0b:23:9c:3e
        [Link]
        Name=eth-pc

/etc/resolv.conf:
  file.managed:
    - contents: |
        domain pws
        search pws
        nameserver 10.80.0.1

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
