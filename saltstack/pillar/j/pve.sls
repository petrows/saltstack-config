# Config for Julia RPI

{% import_yaml 'static.yaml' as static %}

timezone: Europe/Moscow

packages:
  - wireguard

check_mk_plugins:
  - smart

iptables:
  strict_mode: False

# Mount external data storage via USB
mounts:
  j_data:
    name: /mnt/julia-data
    device: /dev/disk/by-id/ata-WDC_WDS100T1R0A-68A4W0_22371A802931-part1
    type: ext4
    opts: defaults

# Allow SSH from PVE
ssh:
  keys:
    root@pve.pws:
      user: root
      enc: ssh-ed25519
      key: AAAAC3NzaC1lZDI1NTE5AAAAILO4R2eYkW2YUGB1VBu5XlNRdNlJwceBDEJrNfRtKz/8
