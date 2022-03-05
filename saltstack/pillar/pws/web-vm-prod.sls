{% import_yaml 'static.yaml' as static %}

roles:
  - php-docker
  - mounts
  - wireguard-server

# Mount external data storage for DMZ host
mounts:
  web_data:
    name: /mnt/data
    device: /dev/mapper/data--vg-data--lv
    type: ext4
    opts: defaults

# Force generate new dhparm keys for Nginx (required for external servers)
nginx:
  dhparam: True

wireguard-server:
  'sb0y':
    port: 5566 # Port listen
    address: '10.80.6.1/24' # Server VPN address

# Web sites
proxy_vhosts:
  petro-wp-www:
    type: redirect
    domain: www.petro.ws
    ssl: external
    redirect_target: 'https://petro.ws/'
    enable_robots: True
  petro-wp:
    type: php-docker
    domain: petro.ws
    ssl: external
    enable_robots: True
    root: /srv/petro-wp
    port: {{ static.proxy_ports.petro_wp_http }}
    php:
      user: www-data
      version: 7.4
      cron:
        wp-cron:
          calendar: '*-*-* *:*:00'
          cmd: php wp-cron.php
      cfg:
        post_max_size: 1G
        upload_max_filesize: 1G
        memory_limit: 1G
      db:
        type: mariadb
        image: mariadb:10.7
        dbname: petro_wp
        credentials: petrows_db
