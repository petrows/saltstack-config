# Force generate new dhparm keys for Nginx (required for external servers)
nginx:
  dhparam: True

proxy_vhosts:
  eu-petrows-default:
    type: folder
    root: /home/www/default/web
    domain: eu.petro.ws
    force_ssl: false
    ssl: external
