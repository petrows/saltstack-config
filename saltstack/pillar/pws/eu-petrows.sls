# Force generate new dhparm keys for Nginx (required for external servers)
nginx:
  dhparam: True
  php: True
  php_pkg: 'php7.0-fpm'
  php_sock: '/var/run/php/php7.0-fpm.sock'

proxy_vhosts:
  eu-petrows-default:
    type: folder
    root: /home/www/default/web
    domain: eu.petro.ws
    force_ssl: false
    ssl: external
  petrows-blog:
    type: php
    root: /home/www/petro.ws/blog
    domain: petro.ws
    ssl: external
