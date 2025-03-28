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
      - i3
      - i3lock-fancy
      - compton
      - udiskie
      - rofi
      - feh
      - network-manager-gnome
      - numlockx
      - apt-file
      - ncal
      # Audio
      - pipewire-audio
      - pipewire-alsa
      - pasystray
      - pavucontrol
      - playerctl
      # Set default QT-Driven apps
      - qt5ct
      # Set default GTK-Driven apps
      - gtk-chtheme
      # GTK Front for Libreoffice
      - libreoffice-gtk3
      # BT tooling
      - blueman
      - rfkill
      # Bat-cat tool: https://github.com/sharkdp/bat
      - bat
      # File manager
      - doublecmd-qt
      {% if grains.osfinger in ['Ubuntu-24.04'] %}
      - libunrar5t64
      {% else %}
      - libunrar5
      {% endif %}
      - unrar
      # Clipboard manipulation
      - xclip
      # Video player
      - vlc
      - vlc-plugin-base
      # PW manager
      - keepassxc
      # Text editor
      - kate
      - okteta
      # Media viewers
      - okular
      - gwenview
      # Log viewer
      - glogg
      - kdiff3
      # Desktop notifications
      - libnotify-bin
      - dunst
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
    - file: /etc/apt/sources.list.d/vscode.list
    - key_url: https://packages.microsoft.com/keys/microsoft.asc
    - clean_file: True

# Vagrant
vagrant-repo:
  pkgrepo.managed:
    - name: deb [arch={{ grains.osarch }}] https://apt.releases.hashicorp.com {{ grains.oscodename }} main
    - file: /etc/apt/sources.list.d/vagrant.list
    - key_url: https://apt.releases.hashicorp.com/gpg
    - clean_file: True

# Lens IDE
lens-repo:
  pkgrepo.managed:
    - name: deb https://downloads.k8slens.dev/apt/debian stable main
    - file: /etc/apt/sources.list.d/lens.list
    - key_url: https://downloads.k8slens.dev/keys/gpg
    - clean_file: True

# Kustomize
kustomize-installer:
  archive.extracted:
    - name: /opt/kustomize-{{ pillar.kustomize.version }}/
    - source: https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv{{ pillar.kustomize.version }}/kustomize_v{{ pillar.kustomize.version }}_linux_amd64.tar.gz
    - skip_verify: True
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
    - skip_verify: True
    - enforce_toplevel: False

/usr/local/bin/vmctl:
  file.symlink:
    - target: /opt/vmutils-{{ pillar.vmutils.version }}/vmctl-prod
    - force: True
    - require:
      - archive: vmutils-installer

# Loop over allowed users on this server
{% for user_id, user in salt['pillar.get']('users', {}).items() %}
local-pc-configs-{{ user_id }}:
  file.recurse:
    - name: {{user.home}}/.config
    - source: salt://files/linux-config/home-local-pc/.config
    - template: jinja
    - user: {{user_id}}
    - group: {{user_id}}

local-pc-local-{{ user_id }}:
  file.recurse:
    - name: {{user.home}}/.local
    - source: salt://files/linux-config/home-local-pc/.local
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

# Apps config
{% for file_id, file_data in salt['pillar.get']('i3:apps_config_ini', {}).items() %}
{% set file_data = file_data|yaml %}
{% set file_data = file_data|replace("%HOME%", user.home) %}
{% set file_data = file_data|replace("%HOSTID%", grains.id) %}
{{user.home}}/.config/{{ file_id }}:
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

# Udev rules
udev-user:
  file.recurse:
    - name: /etc/udev/rules.d/
    - source: salt://files/linux-config/udev/

# Fix wine config:
# See: https://bugs.launchpad.net/ubuntu/+source/wine/+bug/2045127
/etc/binfmt.d/wine.conf:
  file.managed:
    - makedirs: True
    - contents: |
        :Wine:M::MZ::/usr/bin/wine:

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

