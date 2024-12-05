# Common config for ProxMox hosts

# Umount swap
pve-swap-umnount:
  mount.unmounted:
    - name: none
    - device: /dev/pve/swap
    - persist: True

/usr/sbin/pct-stop-all:
  file.managed:
    - mode: 755
    - contents: |
        #!/bin/bash

        CT_LIST=$(pct list | grep running | sed 's/|/ /' | awk '{print $1}')

        for CT in $CT_LIST; do
          echo "Stopping CT $CT"
          pct stop $CT
        done

        VM_LIST=$(qm list | grep running | sed 's/|/ /' | awk '{print $1}')

        for VM in $VM_LIST; do
          echo "Stopping VM $VM"
          qm stop $VM
        done

# Load overlay module to allow run docker in CT

pve-modules:
  kmod.present:
    - persist: True
    - mods:
      - overlay

# Common packages
pve-packages:
  pkg.installed:
    - pkgs:
      - ifupdown2
      # Time sync
      - ntp
      # Wireguard for LXC
      - wireguard

systemd-timesyncd.service:
  service.masked: []

ntp.service:
  service.running:
    - enable: True
    - require:
      - pkg: pve-packages

# Users mapping for unprevileged containers

/etc/subuid:
  file.managed:
    - contents: |
        root:0:6553600
        salt:6553600:65536
        master:6619136:65536

/etc/subgid:
  file.managed:
    - contents: |
        root:0:6553600
        salt:6553600:65536
        master:6619136:65536

# PVE repos
pve-repository:
  pkgrepo.managed:
    - file: /etc/apt/sources.list.d/pve.list
    - name: deb http://download.proxmox.com/debian/pve {{ grains['oscodename'] }} pve-no-subscription
    - clean_file: True

# Remove proprietary repos
/etc/apt/sources.list.d/pve-enterprise.list:
  file.absent: []
/etc/apt/sources.list.d/ceph.list:
  file.absent: []

# PVE UI certificates
/etc/pve/local/pveproxy-ssl.pem:
  file.managed:
    - mode: 640
    - contents_pillar: {{ pillar.pve.ssl_certs }}:crt
/etc/pve/local/pveproxy-ssl.key:
  file.managed:
    - mode: 640
    - contents_pillar: {{ pillar.pve.ssl_certs }}:key
pveproxy.service:
  service.running:
    - watch:
      - file: /etc/pve/local/*

# Install AmneziaWG as kernel module
# amnezia-repo:
#   pkgrepo.managed:
#     - name: deb https://ppa.launchpadcontent.net/amnezia/ppa/ubuntu focal main
#     - file: /etc/apt/sources.list.d/amnezia.list
#     - clean_file: True
#     - keyid: 75C9DD72C799870E310542E24166F2C257290828
#     - keyserver: keyserver.ubuntu.com

# amnezia-src-repo:
#   pkgrepo.managed:
#     - name: deb-src https://ppa.launchpadcontent.net/amnezia/ppa/ubuntu focal main
#     - file: /etc/apt/sources.list.d/amnezia-src.list
#     - clean_file: True
#     - keyid: 75C9DD72C799870E310542E24166F2C257290828
#     - keyserver: keyserver.ubuntu.com

# amnezia-pkg:
#   pkg.installed:
#     - pkgs:
#       - amneziawg
