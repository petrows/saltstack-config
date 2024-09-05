{% import_yaml 'static.yaml' as static %}

roles:
  - wireguard-server

# AWG requires to setup deb-src!
apt:
  use_src: True

{#

Configuration example for pillar:

wireguard-server:
  'server-name':
    port: 443 # Port listen
    address: '10.80.3.1/24' # Server VPN address

Config requires that all private and public keys
must be avliable via:

Server:
pws_secrets:wireguard:<server-name>:server:
  public: X
  private: Y

Client(s) - iterated for secrets pillar
pws_secrets:wireguard:<server-name>:client:<client-name>:
  public: X
  private: Y
  address: '10.80.3.5' # VPN address for client
#}
