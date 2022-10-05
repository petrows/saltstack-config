{% import_yaml 'static.yaml' as static %}

roles:
  - l2tp-server

{#

Configuration example for pillar:

l2tp-server:
    name: <server-name>
    address: '10.80.3.1/24' # Server VPN address
    range: '10.80.3.2-10.80.3.254' # Server VPN pool

Config requires that all private and public keys
must be avliable via:

Client(s) - iterated for secrets pillar
pws_secrets:l2tp:<server-name>:client:<client-name>:
  username: X
  password: Y
  address: '10.80.3.5' # VPN address for client (optional)
#}
