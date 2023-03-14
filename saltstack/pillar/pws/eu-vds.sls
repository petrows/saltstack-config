roles:
  - wireguard-server
  - l2tp-server
  - dante

# VPN
wireguard-server:
  'eu-pws':
    port: 465 # Port listen
    address: '10.80.8.1/24' # Server VPN address

l2tp-server:
    name: eu-pws
    address: '10.80.9.1'
    range: '10.80.9.2-10.80.9.254'

dante:
  port: 13380
  if: wg-eu-pws
  if_external: ens160

iptables:
  ports_open:
    dante:
      dst: 13380
