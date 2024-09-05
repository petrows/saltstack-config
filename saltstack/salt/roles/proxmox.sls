# Common config for ProxMox hosts

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

# Wireguard for LXC

pve-wireguard-pkg:
  pkg.installed:
    - pkgs:
      - wireguard

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
