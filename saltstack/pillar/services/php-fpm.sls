roles:
  - php-fpm

# Some basic config
php:
  # User to own process (but NOT socket)
  user: www
  # chroot base dir
  home: /home/www
