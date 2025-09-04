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
            hwaddress 4c:ed:fb:98:0d:91
            address {{ pillar.static_network.hosts.pws_pve.lan.ipv4.addr }}/{{ pillar.static_network.hosts.pws_pve.lan.ipv4.size }}
            gateway {{ pillar.static_network.networks.pws_lan.ipv4.gw }}
            bridge_ports eth-lan eth-pc
            bridge_vlan_aware yes
            bridge-vids 2-4094
            bridge_stp off
            bridge_fd 0
            post-up iptables-nft -t nat -A PREROUTING -p tcp -d {{ pillar.static_network.hosts.pws_pve.lan.ipv4.addr }} --dport 443 -j REDIRECT --to-ports 8006

        iface vmbr0 inet6 static
            address {{ pillar.static_network.hosts.pws_pve.lan.ipv6.addr }}/{{ pillar.static_network.hosts.pws_pve.lan.ipv6.size }}
            gateway {{ pillar.static_network.networks.pws_lan.ipv6.gw }}
            post-up ip6tables-nft -t nat -A PREROUTING -p tcp -d {{ pillar.static_network.hosts.pws_pve.lan.ipv6.addr }} --dport 443 -j REDIRECT --to-ports 8006

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

# APC config
/etc/apcupsd/apcupsd.conf:
  file.managed:
    - makedirs: True
    - contents: |
        ## apcupsd.conf v1.1 ##
        UPSCABLE usb
        UPSTYPE usb
        # The ONBATTERYDELAY is the time in seconds from when a power failure
        #   is detected until we react to it with an onbattery event.
        #
        #   This means that, apccontrol will be called with the powerout argument
        #   immediately when a power failure is detected.  However, the
        #   onbattery argument is passed to apccontrol only after the
        #   ONBATTERYDELAY time.  If you don't want to be annoyed by short
        #   powerfailures, make sure that apccontrol powerout does nothing
        #   i.e. comment out the wall.
        ONBATTERYDELAY 6
        # If during a power failure, the remaining battery percentage
        # (as reported by the UPS) is below or equal to BATTERYLEVEL,
        # apcupsd will initiate a system shutdown.
        BATTERYLEVEL 30
        # If during a power failure, the remaining runtime in minutes
        # (as calculated internally by the UPS) is below or equal to MINUTES,
        # apcupsd, will initiate a system shutdown.
        MINUTES 10
        # Location of files
        LOCKFILE /var/lock
        SCRIPTDIR /etc/apcupsd
        PWRFAILDIR /etc/apcupsd
        NOLOGINDIR /etc
        STATFILE /var/log/apcupsd.status
        EVENTSFILE /var/log/apcupsd.events

apcupsd.service:
  service.running:
    - enable: True
    - watch:
      - file: /etc/apcupsd/*
