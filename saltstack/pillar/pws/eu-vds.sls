roles:
  - wireguard-server

# VPN
wireguard-server:
  'eu-pws':
    port: 465 # Port listen
    address: '10.80.8.1/24' # Server VPN address
