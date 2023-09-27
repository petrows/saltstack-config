roles:
  - wireguard-server
  - dante

packages:
  - vnstat
  - vnstati

{%
  set vpn_users = {
    'petro': {'id': 0},
  }
%}

# VPN
wireguard-server:
  'eu-pws':
    port: 465 # Port listen
    address: '10.80.8.1/24' # Server VPN address
# New users iterate
{% for user, vpn in vpn_users.items() %}
  'eu-{{ user }}':
    port: {{ 27031 + vpn.id }} # Port listen
    network: '10.85.{{ vpn.id }}.0/24'
    address: '10.85.{{ vpn.id }}.1/24' # Server VPN address
{% endfor %}

dante:
  port: 13380
  if: wg-eu-pws
  if_external: ens160

iptables:
  ports_open:
    dante:
      dst: 13380
