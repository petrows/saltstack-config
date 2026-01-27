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
    - 98:47:44:FB:BB:C9 # Company / Soundcore Q30
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
  # version: 8.4
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

# Packages, distributed as single file, installed into /home/devel/tools with symlinks in /usr/local/bin
# Requires to be set: `hash` to verify download integrity for SaltStack (can be direct hash or URL)
pc-appimages:
  bambu-studio:
    # https://github.com/bambulab/BambuStudio/releases/tag/v02.04.00.70
    url: https://github.com/bambulab/BambuStudio/releases/download/v02.04.00.70/Bambu_Studio_ubuntu-24.04_PR-8834.AppImage
    hash: sha256=26bc07dccb04df2e462b1e03a3766509201c46e27312a15844f6f5d7fdf1debd
  freecad:
    # https://github.com/FreeCAD/FreeCAD/releases/tag/1.0.2
    url: https://github.com/FreeCAD/FreeCAD/releases/download/1.0.2/FreeCAD_1.0.2-conda-Linux-x86_64-py311.AppImage
    hash: sha256=e00be00ad9fdb12b05c5002bfd1aa2ea8126f2c1d4e2fb603eb7423b72904f61
