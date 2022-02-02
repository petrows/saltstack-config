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
    enable_robots: True
  # Warning: this service requires cron task
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
    enable_robots: True
  marinakopf-site:
    type: php
    root: /home/www/marinakopf
    domain: marinakopf.eu
    ssl: external
    enable_robots: True

# Cron jobs
systemd-cron:
  wp-cron-petrows-blog:
    calendar: '*-*-* *:*:00'
    user: www
    cwd: /home/www/petro.ws/blog/web
    cmd: php wp-cron.php

# SSH key for backup service
ssh:
  keys:
    root@pve.pws:
      user: root
      key: AAAAC3NzaC1lZDI1NTE5AAAAILO4R2eYkW2YUGB1VBu5XlNRdNlJwceBDEJrNfRtKz/8
      enc: ssh-ed25519
