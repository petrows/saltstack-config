# Config for RU vps

tmp_ramdisk: False

roles:
  - wireguard-server

wireguard-server:
  servers:
    'ru-vds': True
