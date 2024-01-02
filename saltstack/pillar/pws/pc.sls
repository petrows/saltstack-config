roles:
  - docker
  - php-fpm
  - nginx

include:
  - services.nginx

rslsync:
  data_dir: /home/petro/btsync
  user: petro

# I have 4K displays
xsession:
  gtk_scale: 1.0

# Some workstation tuning
sysctl:
  # Allow IDE's to watch large projects
  # See: https://youtrack.jetbrains.com/articles/IDEA-A-2/Inotify-Watches-Limit
  fs.inotify.max_user_watches: 524288

# Define default apps for workspaces
i3:
  bt_headphones:
    - AC:12:2F:E6:56:A9 # Company / Soundcore Life Q30
  apps_ws:
    - class: Spotify
      ws: 2
    - class: ^TelegramDesktop$
      ws: 2
    - class: ^Code$
      ws: 1

# PHP development
php:
  # PHP version avaliable in packages, to be replaced by grains-driven pillar
  version: 8.1
  # User to run pool under
  user_sock: www-data
  # User to own process (but NOT socket)
  user: petro
  # chroot base dir
  home: /home/www
  # Pool filename in /etc/php/<version>/fpm/pool.d/
  pool_name: www

# Led indicator idle script
systemd-cron:
  pws-led-idle:
    user: root
    # Every 5 min
    calendar: '*:0/5'
    cwd: /tmp
    cmd: /usr/local/bin/led-indicator-idle
