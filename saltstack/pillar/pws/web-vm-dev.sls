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
      cfg:
        upload_max_filesize: 123M
        memory_limit: 99M
      db:
        type: mariadb
        image: mariadb:10.7
        dbname: petro_wp
        credentials: petrows_db
