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

/etc/network/interfaces:
  file.managed:
    - contents: |
        auto lo
        iface lo inet loopback

        # LAN interface
        iface eth-lan inet manual

        # LAN VMs
        auto vmbr0
        iface vmbr0 inet static
            hwaddress 00:4d:54:62:ac:00
            address 10.82.0.4/24
            gateway 10.82.0.1
            bridge_ports eth-lan
            bridge_vlan_aware yes
            bridge-vids 2-4094
            bridge_stp off
            bridge_fd 0

        # GUEST
        auto vmbr0.3
        iface vmbr0.3 inet manual

        # VPN
        auto vmbr0.4
        iface vmbr0.4 inet manual

# Interfaces names
/etc/systemd/network/10-interface-lan.link:
  file.managed:
    - contents: |
        # Main lan uplink
        [Match]
        MACAddress=2c:4d:54:62:ac:d4
        [Link]
        Name=eth-lan

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
