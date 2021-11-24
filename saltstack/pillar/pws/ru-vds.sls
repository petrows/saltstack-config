# Config for RU vps

tmp_ramdisk: False

roles:
  - openvpn-server

openvpn-server:
  'ru-vds':
    port: 443
    proto: tcp
    dev: tun
    auth: SHA1
    network: '10.80.2.0'
