roles:
  - mounts

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
