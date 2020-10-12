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
      - network-manager-gnome
      - numlockx
