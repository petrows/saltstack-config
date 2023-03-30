# Config for Julia RPI

{% import_yaml 'static.yaml' as static %}

timezone: Europe/Moscow

check_mk_plugins:
  - smart
  - mk_docker.py

roles:
  - wireguard-server

include:
  - services.nginx

iptables:
  strict_mode: False

{# wireguard-server:
  'julia-pws':
    address: 10.80.7.6/32 #}

# Mount external data storage via USB
mounts:
  j_data:
    name: /mnt/julia-data
    device: /dev/disk/by-id/scsi-SWDC_WDS_100T1R0A-68A4W0_4C41107427B62005-part1
    type: ext4
    opts: defaults

# Allow SSH from PVE
ssh:
  keys:
    root@pve.pws:
      user: root
      enc: ssh-ed25519
      key: AAAAC3NzaC1lZDI1NTE5AAAAILO4R2eYkW2YUGB1VBu5XlNRdNlJwceBDEJrNfRtKz/8

proxy_vhosts:
  media:
    type: folder
    domain: media.j.pws
    root: /mnt/julia-data/storage/Фильмы/
    ssl_force: False
    ssl: internal
    ssl_name: j_pws
