
local-laptop-soft:
  pkg.latest:
    - pkgs:
      - light
      # BT support and audio
      - bluez-alsa-utils
      - bluez
      - blueman
