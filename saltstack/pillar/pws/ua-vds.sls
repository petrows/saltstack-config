# Config for RU vps

tmp_ramdisk: False

roles:
  - openvpn-server

openvpn-server:
  'ua-vds':
    port: 443
    proto: tcp
    dev: tun
    auth: SHA1
    network: '10.80.3.0'
