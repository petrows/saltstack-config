# Config for RU vps

tmp_ramdisk: False

roles:
  - wireguard-server

wireguard-server:
  'ru-vds':
    port: 443 # Port listen
    address: '10.80.3.1/24' # Server VPN address
