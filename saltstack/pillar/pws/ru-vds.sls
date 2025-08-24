# Config for RU vps

tmp_ramdisk: False

roles:
  - wireguard-server

wireguard-server:
  'ru-vds':
    port: 443 # Port listen
    address: '10.80.3.1/24' # Server VPN address

# Allow home VPN to access machine
firewall:
  hosts_open:
    # Allow ping
    wg_pws:
      source: 10.80.3.8
      proto: icmp
