{% import_yaml 'static.yaml' as static %}

roles:
  - php-docker
  - nginx

proxy_vhosts:
  test-host:
    type: php-docker
    domain: php.local.pws
    ssl_force: False
    ssl: internal
    ssl_name: local
    root: /home/test-host
    port: 8765
    php:
      user: www-data
      version: 7.4
      cron:
        wp-cron:
          calendar: '*-*-* *:*:00'
          cmd: php wp-cron.php
      cfg:
        upload_max_filesize: 123M
        memory_limit: 99M
      db:
        type: mariadb
        image: mariadb:10.7
        dbname: petro_wp
        credentials: petrows_db
  php-8:
    type: php-docker
    domain: php8.local.pws
    ssl_force: False
    ssl: internal
    ssl_name: local
    root: /srv/php8
    port: 8766
    php:
      user: www-data
      version: 8.1
