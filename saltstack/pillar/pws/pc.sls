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
    # https://github.com/bambulab/BambuStudio/releases/tag/v02.06.00.51
    url: https://github.com/bambulab/BambuStudio/releases/download/v02.06.00.51/BambuStudio_ubuntu-24.04-v02.06.00.51-20260417160415.AppImage
    hash: sha256=09878f79f27b1577002be397b0868d447926975f0103bba6e16dbe7fa978f734
  freecad:
    # https://github.com/FreeCAD/FreeCAD/releases/tag/1.1.1
    url: https://github.com/FreeCAD/FreeCAD/releases/download/1.1.1/FreeCAD_1.1.1-Linux-x86_64-py311.AppImage
    hash: sha256=e2006138400b2fa85fa2e160e872d00767eb32964e85075830f7e198a3a876e1

# Pip soft
packages_pip3:
  - keepmenu

pc-autorun:
  # Manage displays and apply settings (kanshi)
  # https://wiki.archlinux.org/title/Kanshi
  display:
    cmd: kanshi
    # We should restart service in Sway reload
    start_mode: restart
