# Config for Julia PVE server host

# This option is required for nested CT from Proxmox 6.3-3
# https://forum.proxmox.com/threads/docker-in-lxc-l%C3%A4uft-nicht-mehr.83651/
net.ipv4.ip_forward:
  sysctl.present:
    - value: 1

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
            hwaddress e8:03:9a:e4:c8:0a
            address {{ pillar.static_network.hosts.m_pve.lan.ipv4.addr }}/{{ pillar.static_network.hosts.m_pve.lan.ipv4.size }}
            gateway {{ pillar.static_network.networks.m_lan.ipv4.gw }}
            bridge_ports eth-lan
            bridge_vlan_aware yes
            bridge-vids 2-4094
            bridge_stp off
            bridge_fd 0
            post-up iptables -t nat -A PREROUTING -p tcp -d {{ pillar.static_network.hosts.m_pve.lan.ipv4.addr }} --dport 443 -j REDIRECT --to-ports 8006

# Interfaces names
/etc/systemd/network/10-interface-lan.link:
  file.managed:
    - contents: |
        # Main lan uplink
        [Match]
        MACAddress=e8:03:9a:e4:c8:0a
        [Link]
        Name=eth-lan
