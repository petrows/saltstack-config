roles:
  - wireguard-server

# Force generate new dhparm keys for Nginx (required for external servers)
nginx:
  dhparam: True

proxy_vhosts:
  eu-petrows-default:
    type: folder
    root: /home/www/default/web
    domain: eu.petro.ws
    ssl_force: false
    ssl: external
  marinakopf-site:
    type: php
    root: /home/www/marinakopf
    domain: marinakopf.eu
    ssl: external
    enable_robots: True

# SSH key for backup service
ssh:
  keys:
    root@pve.pws:
      user: root
      key: AAAAC3NzaC1lZDI1NTE5AAAAILO4R2eYkW2YUGB1VBu5XlNRdNlJwceBDEJrNfRtKz/8
      enc: ssh-ed25519

# VPN
wireguard-server:
  'eu-pws':
    port: 465 # Port listen
    address: '10.80.8.1/24' # Server VPN address
