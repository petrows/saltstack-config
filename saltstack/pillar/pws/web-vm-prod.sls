roles:
  - mounts
  - wireguard-server

# Mount external data storage for DMZ host
mounts:
  web_data:
    name: /mnt/data
    device: /dev/mapper/data--vg-data--lv
    type: ext4
    opts: defaults

# Force generate new dhparm keys for Nginx (required for external servers)
nginx:
  dhparam: True

wireguard-server:
  'sb0y':
    port: 5566 # Port listen
    address: '10.80.6.1/24' # Server VPN address
