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
      # Bat-cat tool: https://github.com/sharkdp/bat
      - bat

# Bluetooth - configure for hi-res profiles
/etc/bluetooth/main.conf:
  file.managed:
    - contents: |
        # This file is managed by Salt
        [General]
        # Enable hi-res profile
        Enable = Source,Sink,Media,Socket
        # Allow to switch profiles
        MultiProfile = multiple
        # Default config
        [Policy]
        AutoEnable=true

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

# Loop over allowed users on this server
{% for user_id, user in salt['pillar.get']('users', {}).items() %}
local-pc-configs-{{ user_id }}:
  file.recurse:
    - name: {{user.home}}/.config
    - source: salt://files/linux-config/home-local-pc/.config
    - template: jinja
    - user: {{user_id}}
    - group: {{user_id}}
{% endfor %}
