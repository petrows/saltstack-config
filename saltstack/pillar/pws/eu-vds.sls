roles:
  - wireguard-server
  - l2tp-server

# VPN
wireguard-server:
  servers:
    'eu-pws': True

l2tp-server:
    name: eu-pws
    address: '10.80.9.1'
    range: '10.80.9.2-10.80.9.254'
