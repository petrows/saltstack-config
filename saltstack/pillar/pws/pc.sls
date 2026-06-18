roles:
  - docker
  - php-fpm
  - nginx
  - cups

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
    # https://github.com/bambulab/BambuStudio/releases/tag/v02.07.01.57
    url: https://github.com/bambulab/BambuStudio/releases/download/v02.07.01.57/BambuStudio_ubuntu-24.04-v02.07.01.57-20260601192128.AppImage
    hash: sha256=85b053853f1a238775cd7ae2d4d19544e35260592428d2276ca27dcbd5f8eb53
    env:
      # Enforce Wayland for this app
      QT_QPA_PLATFORM: wayland
  freecad:
    # https://github.com/FreeCAD/FreeCAD/releases/tag/1.1.1
    url: https://github.com/FreeCAD/FreeCAD/releases/download/1.1.1/FreeCAD_1.1.1-Linux-x86_64-py311.AppImage
    hash: sha256=e2006138400b2fa85fa2e160e872d00767eb32964e85075830f7e198a3a876e1
    env:
      # Enforce Wayland for this app
      QT_QPA_PLATFORM: wayland
  aptakube:
    # https://github.com/aptakube/aptakube/releases/tag/1.17.2
    url: https://github.com/aptakube/aptakube/releases/download/1.17.2/aptakube_1.17.2_amd64.AppImage
    hash: sha256=5d8930baf17554b0a319f91dae246fe8c9d66b73fdbb5170d94e25dfd7a3e620

# Packages, distributed as archive file, installed into /home/devel/tools with optional symlinks in /usr/local/bin
# Requires to be set: `hash` to verify download integrity for SaltStack (can be direct hash or URL)
pc-tools:
  loki-cli:
    # https://github.com/grafana/loki/releases/tag/v3.7.0
    url: https://github.com/grafana/loki/releases/download/v3.7.0/logcli-linux-amd64.zip
    hash: sha256=0406443436565eec6262fd818723242118b7ab08c37f40f1fb7ffcb5e270f8f7
    symlink:
      logcli-linux-amd64: logcli
  winbox:
    # https://mikrotik.com/download/winbox
    url: https://download.mikrotik.com/routeros/winbox/4.1/WinBox_Linux.zip
    hash: sha256=28d35b661c321f5b618936546b7edf6593292549ed4a9584788dadff39a54d8f
    symlink:
      WinBox: winbox

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
  # Auto mount disks
  udiskie:
    cmd: udiskie -ans
    start_mode: restart
  # Network-manager tray icon
  nm-applet:
    cmd: nm-applet
  # Bluetooth tray icon
  blueman-applet:
    cmd: blueman-applet
    start_mode: restart
  # Pulse aution manager icon
  pasystray:
    cmd: pasystray
    start_mode: restart
  # Clipboard manager
  copyq:
    cmd: copyq
    start_mode: restart
  # Password manager
  keepassxc:
    cmd: keepassxc --minimized
  # Telegram desktop
  telegram-desktop:
    cmd: telegram-desktop -startintray
