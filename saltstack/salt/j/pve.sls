# Config for Julia PVE server host

# This option is required for nested CT from Proxmox 6.3-3
# https://forum.proxmox.com/threads/docker-in-lxc-l%C3%A4uft-nicht-mehr.83651/
net.ipv4.ip_forward:
  sysctl.present:
    - value: 1

# Network config
{# pve-net-deps:
  kmod.present:
    - persist: True
    - mods:
      - 8021q
  file.managed:
    - name: /etc/network/interfaces
    - source: salt://files/j-pve/interfaces #}

/etc/udev/rules.d/10-local.rules:
  file.managed:
    - source: salt://files/j-pve/udev-10-local.rules

/etc/default/grub:
  file.managed:
    - source: salt://files/j-pve/grub

/usr/sbin/backup-j-pve:
  file.managed:
    - mode: 755
    - source: salt://files/j-pve/backup-j-pve
