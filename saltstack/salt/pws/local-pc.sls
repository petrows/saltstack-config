# Additional scripts
local-pc-custom-bin:
  file.recurse:
    - name: /usr/local/sbin
    - source: salt://files/linux-config/bin-local-pc
    - template: jinja
    - file_mode: 755

# /etc config
local-pc-custom-etc:
  file.recurse:
    - name: /etc
    - source: salt://files/linux-config/etc-local-pc
    - template: jinja

# Fuse group to allow fuse mounts
fuse-group:
  group.present:
    - name: fuse
    - system: True

# Allow mount PWS folders (mount fuse to /home/)
# See: https://apparmor.narkive.com/J6ZaHFtg/mount-rules
/etc/apparmor.d/local/fusermount3:
  file.managed:
    - contents: |
        mount fstype=@{fuse_types} -> /home/**/,

apparmor-reload:
  cmd.wait:
    - name: systemctl reload apparmor.service
    - watch:
      - file: /etc/apparmor.d/local/*

# Allow direct control of Scroll lock
/usr/share/X11/xkb/compat/ledcaps:
  file.managed:
    - contents: |
        default partial xkb_compatibility "caps_lock" {
            indicator "Caps Lock" {
                whichModState= Locked;
                modifiers= Lock;
            };
        };
        partial xkb_compatibility "group_lock" {
            indicator "Caps Lock" {
                modifiers= None;
                groups=All-group1;
            };
        };
        partial xkb_compatibility "shift_lock" {
            indicator "Caps Lock" {
                whichModState= Locked;
                modifiers= Shift;
            };
        };

local-pc-soft:
  pkg.latest:
    - pkgs:
      # - i3
      # - i3lock-fancy
      # - compton
      # -
      # - rofi
      # -
      #
      # - numlockx
      # -
      # - ncal
      # # Locking / sleep events
      # - xss-lock
      # # Auto display profile switcher
      # - autorandr
      # Sway + Wayland
      - sway
      - waybar
      - wofi
      - swaylock
      - xdg-desktop-portal-wlr
      # Network
      - network-manager-gnome
      # Audio
      - pipewire-audio
      - pipewire-alsa
      - pasystray
      - pavucontrol
      - playerctl
      # Theming
      - breeze-gtk-theme
      - breeze-icon-theme
      - papirus-icon-theme
      # Set default QT-Driven apps
      - qt5ct
      {% if grains.osmajorrelease >= 25 %}
      - qt6ct
      {% endif %}
      # Set default GTK-Driven apps
      # - gtk-chtheme
      # GTK Front for Libreoffice
      - libreoffice-gtk3
      # BT tooling
      - blueman
      - rfkill
      # Bat-cat tool: https://github.com/sharkdp/bat
      - bat
      # Auto maount removable media:
      - udiskie
      # File manager
      - sshfs
      - apt-file
      - doublecmd-qt
      {% if grains.osfinger in ['Ubuntu-24.04'] or grains.osmajorrelease >= 25 %}
      - libunrar5t64
      {% else %}
      - libunrar5
      {% endif %}
      - unrar
      # Other cli tools
      - ncal
      - numlockx
      # Clipboard manipulation
      - xclip
      # Screenshot manipulation
      - flameshot
      # Video player
      - vlc
      - vlc-plugin-base
      # PW manager
      - keepassxc
      # Clipboard manager
      # - xfce4-clipman
      - copyq
      # Text editor
      - kate
      - okteta
      # Media viewers
      - feh
      - okular
      - gwenview
      # Log viewer
      - glogg
      - kdiff3
      # Desktop notifications
      - libnotify-bin
      # - dunst
      - mako-notifier
      # fdfund tool (friendly find): https://github.com/sharkdp/fd
      - fd-find
      # Wine formats
      - binfmt-support
      # Monitoring
      - nagstamon
      # Prepare to migrate
      - ansible
      - ansible-lint
      - ssh-askpass
      # Hardware development
      - esptool
      - minicom
      # Development
      - cmake
      - build-essential
      # Required for some VS Code extensions (i.e. platformio)
      - python3-venv
      # Code tools
      - clang-format
      - pre-commit
      - pylint
      - yamllint

local-pc-soft-cleanup:
  pkg.purged:
    - pkgs:
      # Desktop notifications (old)
      - notify-osd
      # Displays annoying popups as windows
      - notification-daemon
      # Catches KB layout switch
      - fcitx5
      - fcitx

# Bluetooth - configure for hi-res profiles
/etc/bluetooth/main.conf:
  file.managed:
    - contents: |
        # This file is managed by Salt
        [General]
        # Enable auto connect
        FastConnectable = true
        # Enable hi-res profile
        # Enable = Source,Sink,Media,Socket
        # Allow to switch profiles
        MultiProfile = multiple
        # Allow experimental features, like Battery level
        Experimental = true
        # Default config
        [Policy]
        AutoEnable=true
        ReconnectAttempts=7

bluetooth.service:
  service.running:
    - enable: True
    - watch:
      - file: /etc/bluetooth/*

# Sgrok software
sigrok-software:
  pkg.installed:
    - pkgs:
      - pulseview
      - sigrok
      - sigrok-cli
      - sigrok-firmware-fx2lafw

# Patch Sigrok to support Hantek 6022BL logic analyser with 16 channels
# See: https://michlstechblog.info/blog/pulseview-sigrok-use-hantek-6022bl-with-16-channels-linux-debian/
# See: https://www.eevblog.com/forum/testgear/hantek-6022bl-logic-analyzer-working-with-sigrok-all-16-channels
# Copy another firmware to replace original one. Replace back in case of issues
/usr/share/sigrok-firmware/fx2lafw-saleae-logic.fw:
  file.managed:
    - source: salt://files/sigrok/fx2lafw-saleae-logic-16ch.fw
    #- source: salt://files/sigrok/fx2lafw-saleae-logic-original.fw

# OpenHantek DSO
/opt/OpenHantek6022.deb:
  file.managed:
    - source: https://github.com/OpenHantek/OpenHantek6022/releases/download/3.4.0/openhantek_3.4.0_amd64.deb
    - source_hash: e86d88910537e6f1b9759deb6111b6db

openhantek-soft:
  pkg.installed:
    - sources:
      - openhantek: /opt/OpenHantek6022.deb

# Telegram-desktop
# Clean installed one
local-tg-remove-pkg:
  pkg.purged:
    - pkgs:
      - telegram-desktop

local-tg-installer:
  archive.extracted:
    - name: /opt/telegram-{{ pillar.telegram.version }}/
    - source: https://github.com/telegramdesktop/tdesktop/releases/download/v{{ pillar.telegram.version }}/tsetup.{{ pillar.telegram.version }}.tar.xz
    - source_hash: {{ pillar.telegram.hash }}

local-tg-binary:
  file.symlink:
    - name: /usr/local/bin/telegram-desktop
    - target: /opt/telegram-{{ pillar.telegram.version }}/Telegram/Telegram
    - force: True
    - require:
      - archive: local-tg-installer

# VS Code
/etc/apt/sources.list.d/vscode.sources:
  file.managed:
    - contents: |
        X-Repolib-Name: Visual Studio Code
        Description: Visual Studio Code is a code editor redefined and optimized for building and debugging modern web and cloud applications.
          - Website: https://code.visualstudio.com
          - Public key: https://packages.microsoft.com/keys/microsoft.asc
        Enabled: yes
        Types: deb
        URIs: https://packages.microsoft.com/repos/vscode
        Signed-By: /etc/apt/keyrings/microsoft.gpg
        Suites: stable
        Components: main

# # Vagrant
/etc/apt/sources.list.d/vagrant.sources:
  file.managed:
    - contents: |
        X-Repolib-Name: Vagrant
        Description: Vagrant is a tool for building and managing virtual machine environments in a single workflow.
          - Website: https://www.vagrantup.com
          - Public key: https://apt.releases.hashicorp.com/gpg
        Enabled: yes
        Types: deb
        URIs: https://apt.releases.hashicorp.com
        Signed-By: /etc/apt/keyrings/vagrant.gpg
        # Broken on Ubuntu 25.X
        # Suites: {{ grains.oscodename }}
        Suites: noble
        Components: main

# Lens IDE
/etc/apt/sources.list.d/lens.sources:
  file.managed:
    - contents: |
        X-Repolib-Name: Lens IDE
        Description: Lens is the only IDE you need to take control of your Kubernetes clusters.
          - Website: https://k8slens.dev
          - Public key: https://downloads.k8slens.dev/keys/gpg
        Enabled: yes
        Types: deb
        URIs: https://downloads.k8slens.dev/apt/debian
        Signed-By: /etc/apt/keyrings/lens.gpg
        Suites: stable
        Components: main

# Kustomize
kustomize-installer:
  archive.extracted:
    - name: /opt/kustomize-{{ pillar.kustomize.version }}/
    - source: https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv{{ pillar.kustomize.version }}/kustomize_v{{ pillar.kustomize.version }}_linux_amd64.tar.gz
    - source_hash: {{ pillar.kustomize.hash }}
    - enforce_toplevel: False

/usr/local/bin/kustomize:
  file.symlink:
    - target: /opt/kustomize-{{ pillar.kustomize.version }}/kustomize
    - force: True
    - require:
      - archive: kustomize-installer

# Victoria logs cli
vlogscli-installer:
  archive.extracted:
    - name: /opt/vlogscli-{{ pillar.vlogscli.version }}/
    - source: https://github.com/VictoriaMetrics/VictoriaMetrics/releases/download/v{{ pillar.vlogscli.version }}-victorialogs/vlogscli-linux-amd64-v{{ pillar.vlogscli.version }}-victorialogs.tar.gz
    - source_hash: https://github.com/VictoriaMetrics/VictoriaMetrics/releases/download/v{{ pillar.vlogscli.version }}-victorialogs/vlogscli-linux-amd64-v{{ pillar.vlogscli.version }}-victorialogs_checksums.txt
    - skip_verify: True
    - enforce_toplevel: False

/usr/local/bin/vlogscli:
  file.symlink:
    - target: /opt/vlogscli-{{ pillar.vlogscli.version }}/vlogscli-prod
    - force: True
    - require:
      - archive: vlogscli-installer

# Victoria metrics cli
vmutils-installer:
  archive.extracted:
    - name: /opt/vmutils-{{ pillar.vmutils.version }}/
    - source: https://github.com/VictoriaMetrics/VictoriaMetrics/releases/download/v{{ pillar.vmutils.version }}/vmutils-linux-amd64-v{{ pillar.vmutils.version }}.tar.gz
    - source_hash: https://github.com/VictoriaMetrics/VictoriaMetrics/releases/download/v{{ pillar.vmutils.version }}/vmutils-linux-amd64-v{{ pillar.vmutils.version }}_checksums.txt
    - enforce_toplevel: False

/usr/local/bin/vmctl:
  file.symlink:
    - target: /opt/vmutils-{{ pillar.vmutils.version }}/vmctl-prod
    - force: True
    - require:
      - archive: vmutils-installer

# GitHub Copilot CLI
copilot-cli-installer:
  archive.extracted:
    - name: /opt/copilot-cli-{{ pillar['copilot-cli'].version }}/
    - source: https://github.com/github/copilot-cli/releases/download/v{{ pillar['copilot-cli'].version }}/copilot-linux-x64.tar.gz
    - source_hash: {{ pillar['copilot-cli'].hash }}
    - enforce_toplevel: False

/usr/local/bin/copilot:
  file.symlink:
    - target: /opt/copilot-cli-{{ pillar['copilot-cli'].version }}/copilot
    - force: True
    - require:
      - archive: copilot-cli-installer

# Loop over allowed users on this server
{% for user_id, user in salt['pillar.get']('users', {}).items() %}
local-pc-configs-{{ user_id }}:
  file.recurse:
    - name: {{user.home}}/.config
    - source: salt://files/linux-config/home-local-pc/.config
    - template: jinja
    - user: {{user_id}}
    - group: {{user_id}}
    - file_mode: keep

local-pc-local-{{ user_id }}:
  file.recurse:
    - name: {{user.home}}/.local
    - source: salt://files/linux-config/home-local-pc/.local
    - template: jinja
    - user: {{user_id}}
    - group: {{user_id}}
    - file_mode: keep

# Screenshot folder
{{user.home}}/Pictures/screenshots:
  file.directory:
    - user: {{user_id}}
    - group: {{user_id}}
    - makedirs: True

# File accociations
{{user.home}}/.config/mimeapps.list:
  ini.options_present:
    - separator: '='
    - strict: False
    - no_spaces: True
    - sections:
        Default Applications:
          {% for app_mime,app_desktop in pillar.i3.mime_types.default.items() %}
          {{ app_mime }}: {{ app_desktop }}
          {% endfor %}

# Git-precommit
{{user.home}}/.git-template/hooks/pre-commit:
  file.managed:
    - source: salt://files/pre-commit
    - user: {{user_id}}
    - group: {{user_id}}
    - mode: 0755
    - makedirs: True

# GTK Apps
{% for gtk_v in ['2.0','3.0','4.0'] %}
# Remove some dump files
{{ user.home }}/.config/gtk-{{ gtk_v }}/colors.css:
  file.absent: []
{{ user.home }}/.config/gtk-{{ gtk_v }}/gtk.css:
  file.absent: []
# Configuration
{{ user.home }}/.config/gtk-{{ gtk_v }}/settings.ini:
  file.managed:
    - makedirs: True
    - user: {{ user_id }}
    - group: {{ user_id }}
    - contents: |
        [Settings]
        gtk-enable-animations=0
        gtk-theme-name=Breeze-Dark
        gtk-icon-theme-name=Papirus-Dark
        gtk-application-prefer-dark-theme=1
        gtk-font-name=Noto Sans 10
{% endfor %}
{{ user.home }}/.gtkrc-2.0:
  file.managed:
    - makedirs: True
    - user: {{ user_id }}
    - group: {{ user_id }}
    - contents: |
        gtk-enable-animations=0
        gtk-primary-button-warps-slider=1
        gtk-toolbar-style=3
        gtk-menu-images=1
        gtk-button-images=1
        gtk-cursor-blink-time=1000
        gtk-cursor-blink=1
        gtk-cursor-theme-size=30
        gtk-cursor-theme-name="breeze_cursors"
        gtk-sound-theme-name="ocean"
        gtk-font-name="Noto Sans 10"
        gtk-theme-name="Breeze-Dark"
        gtk-icon-theme-name="Papirus-Dark"
        gtk-application-prefer-dark-theme=1

# File selector dialogs (use KDE + Dark)
# Apply in runtime: systemctl --user restart xdg-desktop-portal
{{ user.home }}/.config/xdg-desktop-portal/portals.conf:
  file.managed:
    - makedirs: True
    - user: {{ user_id }}
    - group: {{ user_id }}
    - contents: |
        [preferred]
        default=kde
        org.freedesktop.impl.portal.FileChooser=kde
        org.freedesktop.impl.portal.Settings=kde
        org.freedesktop.impl.portal.AppChooser=kde
        org.freedesktop.impl.portal.Screenshot=wlr
        org.freedesktop.impl.portal.ScreenCast=wlr

# See: https://wiki.archlinux.org/title/XDG_Desktop_Portal
# In some cases, such as when you have a standalone window manager, you might want to make xdg-desktop-portal to think you are using a specific desktop environment. This can be achieved by setting the XDG_CURRENT_DESKTOP environment variable for the xdg-desktop-portal.service user unit using a drop-in snippet. For example, to use the backend associated with KDE:
# {{ user.home }}/.config/systemd/user/xdg-desktop-portal.service.d/override.conf:
#   file.managed:
#     - makedirs: True
#     - user: {{ user_id }}
#     - group: {{ user_id }}
#     - contents: |
#         [Service]
#         Environment="XDG_CURRENT_DESKTOP=KDE QT_QPA_PLATFORMTHEME=kde"

# Apps config
{% for file_id, file_data in salt['pillar.get']('i3:apps_config_ini', {}).items() %}
{% set file_data = file_data|yaml %}
{% set file_data = file_data|replace("%HOME%", user.home) %}
{% set file_data = file_data|replace("%HOSTID%", grains.id) %}
{{user.home}}/.config/{{ file_id }}:
  file.managed:
    - makedirs: True
    - replace: False
    - user: {{ user_id }}
    - group: {{ user_id }}
    - mode: '0600'
  ini.options_present:
    - separator: '='
    - strict: False
    - sections:
        {{ file_data|indent(8) }}
{% endfor %}

{% endfor %}

# Stop/break annoying nvidia-persistenced service -> does not react on stop
# Jun 11 12:03:03 petro-pc systemd[1]: Started nvidia-persistenced.service - NVIDIA Persistence Daemon.
# Jun 11 12:11:00 petro-pc nvidia-persistenced[1189]: Received signal 15
# Jun 11 12:11:00 petro-pc systemd[1]: Stopping nvidia-persistenced.service - NVIDIA Persistence Daemon...
# Jun 11 12:12:30 petro-pc systemd[1]: nvidia-persistenced.service: State 'stop-sigterm' timed out. Killing.
# Jun 11 12:12:30 petro-pc systemd[1]: nvidia-persistenced.service: Killing process 1189 (nvidia-persiste) with signal SIGKILL.
# Service may be deactivated safely, as it needed only in headless mode.
# See: https://forums.developer.nvidia.com/t/nvidia-persistenced-causing-60-second-reboot-delays/67681

nvidia-persistenced.service:
  service.masked

# Stop / break unattended-upgrades.service, updates installed manually only
unattended-upgrades.service:
  service.masked

# Udev rules
udev-user:
  file.recurse:
    - name: /etc/udev/rules.d/
    - source: salt://files/linux-config/udev/

# Configure local NM connection
/etc/NetworkManager/system-connections/lan.nmconnection:
  file.managed:
    - mode: 0600
    - contents: |
        [connection]
        id=lan
        type=ethernet
        permissions=
        [ethernet]
        wake-on-lan=1
        [ipv4]
        method=auto
        [ipv6]
        method=auto
        addr-gen-mode=1
        [proxy]

/etc/netplan/:
  file.recurse:
    - source: salt://files/linux-config/local-pc/netplan/
    - file_mode: 0600

# Wine-staging
/etc/apt/sources.list.d/wine.sources:
  file.managed:
    - contents: |
        Types: deb
        URIs: https://dl.winehq.org/wine-builds/ubuntu
        Suites: {{ grains.oscodename }}
        Components: main
        Architectures: amd64 i386
        Signed-By: /etc/apt/keyrings/winehq.gpg

wine-soft-remove:
  pkg.removed:
    - pkgs:
      - wine
      - winehq-stable
      - wine-stable-i386
      - wine-stable-amd64
      - wine-stable
      - winetricks
      - wine-binfmt
      - wine64

wine-soft:
  pkg.latest:
    - pkgs:
      - wine-staging

# PATH is set in saltstack/salt/files/linux-config/home/.profile_common.fish

# Fix wine config:
# See: https://bugs.launchpad.net/ubuntu/+source/wine/+bug/2045127
/etc/binfmt.d/wine.conf:
  file.managed:
    - makedirs: True
    - contents: |
        :Wine:M::MZ::/opt/wine-staging/bin/wine:

# Install AppImages from pc-appimages pillar
{% for app_id, app_data in salt['pillar.get']('pc-appimages', {}).items() %}

{% set app_binary_name = app_data.get('filename', app_data.url.split('/') | last) %}

# {{ app_id }} AppImage
/home/devel/tools/{{ app_id }}/{{ app_binary_name }}:
  file.managed:
    - source: {{ app_data.url }}
    - source_hash: {{ app_data.hash }}
    - mode: 0755
    - makedirs: True

# Link to /usr/local/bin
/usr/local/bin/{{ app_id }}:
  file.symlink:
    - target: /home/devel/tools/{{ app_id }}/{{ app_binary_name }}
    - force: True

{% endfor %}

# Kowabunga
# https://packages.kowabunga.cloud/
/etc/apt/sources.list.d/kowabunga.sources:
  file.managed:
    - contents: |
        X-Repolib-Name: Kowabunga
        Enabled: yes
        Types: deb
        URIs: https://packages.kowabunga.cloud/ubuntu
        Suites: noble
        Components: main
        Signed-By: /etc/apt/keyrings/kowabunga.gpg

# Fix SDDM to enforce Wayland (does not work for i3)
/etc/sddm.conf.d/10-wayland.conf:
  file.managed:
    - contents: |
        # Wayland is now live
        [General]
        DisplayServer=wayland
        GreeterEnvironment=QT_WAYLAND_SHELL_INTEGRATION=layer-shell
        [Wayland]
        CompositorCommand=kwin_wayland --drm --no-lockscreen --no-global-shortcuts --locale1

# Common mount / work folders
{% for common_user_folder in ['/home/devel', '/home/pws', '/home/pws-home'] %}
{{ common_user_folder }}:
  file.directory:
  - user: {{ pillar.firefox.user }}
  - group: {{ pillar.firefox.user }}
  - makedirs: True
{% endfor %}
