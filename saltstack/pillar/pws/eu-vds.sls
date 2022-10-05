roles:
  - wireguard-server
  - l2tp-server

# VPN
wireguard-server:
  'eu-pws':
    port: 465 # Port listen
    address: '10.80.8.1/24' # Server VPN address

l2tp-server:
    name: eu-pws
    address: '10.80.9.1'
    range: '10.80.9.2-10.80.9.254'
