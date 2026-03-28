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
    # https://github.com/bambulab/BambuStudio/releases/tag/v02.05.00.67
    url: https://github.com/bambulab/BambuStudio/releases/download/v02.05.00.67/Bambu_Studio_ubuntu-24.04_PR-9540.AppImage
    hash: sha256=dee6d96e5aec389cf3d69df84228b089a80a681ee723cc4379a74558706459f8
  freecad:
    # https://github.com/FreeCAD/FreeCAD/releases/tag/1.1.0
    url: https://github.com/FreeCAD/FreeCAD/releases/download/1.1.0/FreeCAD_1.1.0-Linux-x86_64-py311.AppImage
    hash: sha256=ef85f171f2d09eec93f358bc49c1730d33f72bfbd353e6465609b30e45acf2f0
