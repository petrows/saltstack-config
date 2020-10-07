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
  petrows-blog:
    type: php
    root: /home/www/petro.ws/blog
    domain: petro.ws
    ssl: external
  petrows-trs:
    type: php
    root: /home/www/petro.ws/trs
    domain: trs.petro.ws
    ssl: external
  petrows-tools:
    type: php
    php_rewrite_rule: /index.php?url=$uri&$args
    root: /home/www/petro.ws/tools
    domain: tools.petro.ws
    ssl: external
