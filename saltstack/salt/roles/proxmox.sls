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
