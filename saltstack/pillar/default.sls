# Default pillar values

timezone: Europe/Berlin

# Mount /tmp as ramdisk?
tmp_ramdisk: False

# Additional software
packages: []

# List of packages, will be installed to system venv,
# Use `/opt/venv/system/bin/python` as interpreter
packages_pip3: []

# PIP3 location
pip3_bin: /usr/bin/pip3
python_bin: /opt/venv/app/bin/python
python_system_bin: /usr/bin/python3

# Use 'powerline.segments.common.vcs.branch' for old systems
powerline_git_plugin: 'powerline.segments.common.vcs.branch'
powerline_git_pkg: ''

# If check-mk used, we can install additional plugins to monitor it
check_mk_plugins: {}
# If check-mk used, we can install additional local checks
check_mk_local: {}

# check-mk settings
check_mk_agent:
  install: False
  base: https://cmk.system.pws/cmk/check_mk/agents/
  filename: check-mk-agent_2.2.0p25-1_all.deb
  checksum: edcc2e324ac6f41950be173977f53275

# If set, salt will be armed to auto-apply on connect (default for servers)
salt_auto_apply: False

# All local emails will be delivered to this one
maintainer_email: petro@petro.ws

# Docker-compose config
docker_compose:
  version: 2.16.0
  # Services to be auto-added to run
  services: {}

docker:
  subnet: 172.16.0.0/12
  subnet_size: 24
  ipv6_cidr: fdfd:8b2c:086d:ecbd::/64

# This option forces to update bash / fish profile
force_user_update: False

# Values to ge set as git config for all users passed in 'users' role
git_config:
  core.whitespace: fix, trailing-space
  color.ui: auto
  push.default: tracking
  pull.rebase: "true"
  alias.ca: commit -am
  alias.cap: "commit --author='Petro <petro@petro.ws>' -am"
  alias.l: "log --graph --decorate --pretty=format:'%C(yellow)%h%Creset %s %C(green)(%cr)%Creset' --abbrev-commit --date=relative"
  alias.s: status --short
  alias.checkout-pr: "!f() { git fetch origin pull/$1/head:pr-$1 && git checkout pr-$1; }; f"
  alias.cln: "!f() { git submodule sync; git submodule update --init --remote; git reset --hard --recurse-submodule; git clean -fd; }; f"
  alias.ch: "!f() { git fetch; git checkout -f --recurse-submodules $1; }; f"
  alias.cm: "!f() { git checkout -f --recurse-submodules master; git pull --rebase; }; f"
  alias.cb: checkout -b
  alias.pb: push --set-upstream origin HEAD
  alias.pf: push --force
  alias.d: diff
  alias.dh: diff HEAD
  alias.ds: diff --cached
  alias.wdiff: diff --color-words --ignore-all-space
  alias.co: checkout
  alias.unstage: reset HEAD
  alias.undo: checkout --
  alias.sub-clean: "!f() { git submodule foreach rm -rf .git *; }; f"

# SSH keys for all users to be installed
# ssh:
#  keys:
#    <key-id>: # Name of key
#      type: <type:ssh-ed25519> # Type, same as in .pub
#      key: ...
ssh:
  port: 22
  allow_pw: True
  force_manage: True # Erase keys not exists?
  keys:
    petro@petro.ws:
      enc: ssh-ed25519
      key: AAAAC3NzaC1lZDI1NTE5AAAAIDuBa7ob9ADp3XvpLKFW8tEkoD0gK+Fg0JKzTX36yndl
    petro@work:
      enc: ssh-ed25519
      key: AAAAC3NzaC1lZDI1NTE5AAAAIAUb4j91LRd0dBXMj+QE9uhC1MaKZXz5s5u64ld3uTay
    salt@pws: # See saltstack/pillar/pws/secrets.sls
      user: ^salt$
      enc: ssh-ed25519
      key: AAAAC3NzaC1lZDI1NTE5AAAAINvleX9wOOd2C5M7Wy3sv2XSCXRvYG8iY+U4ONZBueYi
  # Hosts config (for client)
  hosts_config:
    local_no_check_127:
        host: '127.0.0.*'
        config:
          StrictHostKeyChecking: 'no'
    local_no_check_192:
        host: '192.168.*.*'
        config:
          StrictHostKeyChecking: 'no'
    local_no_check_10:
        host: '10.*.*.*'
        config:
          StrictHostKeyChecking: 'no'
    pws_no_check:
        host: '*.pws'
        config:
          StrictHostKeyChecking: 'no'
    internal_no_check:
        host: '*.internal'
        config:
          StrictHostKeyChecking: 'no'

# Define list of hosts, to be managed in sshd config
ssh_machines:
    root.j.pws:
      port: 6446
    wlan.j.pws:
      port: 6446
    root.m.pws:
      port: 6446
    eu.vds.pws:
      port: 8144
    ru.vds.pws:
      port: 8144
    pve.ext.j.pws:
      port: 34123
    media.ext.j.pws:
      port: 20124

iptables:
  strict_mode: False # If true all input traffic will be blocked by default
  allow_ping: True
  ports_open: {} # Ports, which are open for all
  hosts_open: {} # IP's, which has no restrictions
  strings_block: {}

nginx:
  # Force generate new dhparm keys for Nginx (required for external servers)
  dhparam: False

php:
  # PHP version avaliable in packages, to be replaced by grains-driven pillar
  version: 7.3
  # User to run pool under
  user_sock: www-data
  # User to own process (but NOT socket)
  user: www
  # chroot base dir
  home: /home/www
  # Pool filename in /etc/php/<version>/fpm/pool.d/
  pool_name: www

php-docker:
  defaults:
    user: www-data
    container_revision: '2022-08-24'
    cfg:
      display_errors: Off
      log_errors: On
      memory_limit: 1G
      upload_max_filesize: 1G
      post_max_size: 1G

# https://github.com/telegramdesktop/tdesktop/releases
telegram:
  version: 4.16.6

xsession:
  gtk_scale: 1.0

# i3 config options
i3:
  bar_font_size: 12
  display_config_id: petro-pc
  display: ''
  startup: ''
  # Enable compton?
  composite: True
  # Where to read CPU package temperature
  temp_read: /sys/devices/platform/coretemp.0/hwmon/hwmon1/temp1_input
  mime_types:
    default:
      # Use Double commander to open directories
      inode/directory: doublecmd.desktop
      # Use KDE apps to open text types
      text/plain: org.kde.kate.desktop
      text/markdown: org.kde.kate.desktop
      text/x-patch: org.kde.kate.desktop
      # Use KDE apps to open media types
      application/pdf: org.kde.okular.desktop
      application/x-fictionbook+xml: org.kde.okular.desktop
      image/jpeg: org.kde.gwenview.desktop
      image/png: org.kde.gwenview.desktop
      image/svg+xml: org.kde.gwenview.desktop
      image/webp: org.kde.gwenview.desktop
      # Video: VLC
      video/mp4: vlc.desktop
      video/x-ms-wmv: vlc.desktop
      video/x-matroska: vlc.desktop
      video/x-msvideo: vlc.desktop
  # Apps config, uses [ini] format in ~/.config,
  # true for most KDE apps
  apps_config_ini:
    okularpartrc:
      General:
        ShellOpenFileInTabs: 'true'
      Core Performance:
        TextHinting: Enabled
    # Global shortcuts
    kglobalshortcutsrc:
      klipper:
        # Get previous copied item by Ctrl+Shift+C
        cycleNextAction: Ctrl+Shift+C,,Next History Item
    konsolerc:
      Desktop Entry:
        DefaultProfile: Petro.profile
      Notification Messages:
        CloseAllEmptyTabs: 'true'
        CloseAllTabs: 'true'
        CloseSingleTab: 'true'
      TabBar:
        CloseTabButton: None
        CloseTabOnMiddleMouseButton: 'true'
        TabBarVisibility: AlwaysShowTabBar
    spectaclerc:
      General:
        autoSaveImage: 'true'
        clipboardGroup: PostScreenshotCopyImage
        printKeyActionRunning: 0
        rememberLastRectangularRegion: 2
        showMagnifier: 'false'
        useLightMaskColour: 'false'
        useReleaseToCapture: 'false'
      Save:
        compressionQuality: 90
        defaultSaveImageFormat: JPEG
        defaultSaveLocation: file:/%HOME%/Pictures/screenshots
        saveFilenameFormat: Screenshot_%HOSTID%_%Y%M%D_%H%m%S

swap_size_mb: 0

network:
  type: unknown
  ntp: False
  dns: False
  # CDN name to use in mirror
  cdn: de
  # Domain zone of this host
  domain: pws
  # Add hostname as 127.0.0.1?
  hostname_local: True

networks:
  pws:
    - 10.80.0.0/16
    - 10.81.0.0/16
    - 10.82.0.0/16
    - 10.83.0.0/16

users: {}

# Allow auto updates?
upgrades:
  auto: False

# Journald config
journald:
  storage: auto

mount-folders: {}

nfs-exports: {}

kernel-modules: {}

# meta pillar for simple systemd 'crontab'
# avaliable options are:
# calendar - equation when to run
# user - user to set in unit
# cmd - command to call (will be called as /bin/bash -c '<cmd>')
# cwd - workdir
systemd-cron: {}

# Export static registry as pillar to be used in SLS
{% import_yaml 'static.yaml' as static %}
static: {{ static|yaml }}
