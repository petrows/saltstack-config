# Additional scripts
local-pc-custom-bin:
  file.recurse:
    - name: /usr/local/sbin
    - source: salt://files/linux-config/bin-local-pc
    - template: jinja
    - file_mode: 755

local-pc-soft:
  pkg.latest:
    - pkgs:
      - i3
      - compton
      - udiskie
      - rofi
      - feh
      - network-manager-gnome
      - numlockx
      - pasystray
      - playerctl
      # Set default QT-Driven apps
      - qt5ct
      # Set default GTK-Driven apps
      - gtk-chtheme
      # GTK Front for Libreoffice
      - libreoffice-gtk3
      # BT support and audio
      - bluez-alsa-utils
      - bluez
      - blueman
      - rfkill
      # Bat-cat tool: https://github.com/sharkdp/bat
      - bat
      # File manager
      - doublecmd-qt
      # Clipboard manipulation
      - xclip

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
        # Default config
        [Policy]
        AutoEnable=true
        ReconnectAttempts=7

bluetooth.service:
  service.running:
    - enable: True
    - watch:
      - file: /etc/bluetooth/*

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
    - skip_verify: True

local-tg-binary:
  file.symlink:
    - name: /usr/local/bin/telegram-desktop
    - target: /opt/telegram-{{ pillar.telegram.version }}/Telegram/Telegram
    - force: True
    - require:
      - archive: local-tg-installer

# xorg conf
/etc/X11/xorg.conf.d/xorg.touchpad.conf:
  file.managed:
    - source: salt://files/linux-config/xorg.touchpad.conf
    - makedirs: True

# VS Code
vscode-repo:
  pkgrepo.managed:
    - name: deb [arch={{ grains.osarch }}] https://packages.microsoft.com/repos/code stable main
    - key_url: https://packages.microsoft.com/keys/microsoft.asc

# Loop over allowed users on this server
{% for user_id, user in salt['pillar.get']('users', {}).items() %}
local-pc-configs-{{ user_id }}:
  file.recurse:
    - name: {{user.home}}/.config
    - source: salt://files/linux-config/home-local-pc/.config
    - template: jinja
    - user: {{user_id}}
    - group: {{user_id}}

# File accociations
{{user.home}}/.config/mimeapps.list:
  ini.options_present:
    - separator: '='
    - strict: False
    - sections:
        Default Applications:
          {% for app_mime,app_desktop in pillar.i3.mime_types.default.items() %}
          {{ app_mime }}: {{ app_desktop }}
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
