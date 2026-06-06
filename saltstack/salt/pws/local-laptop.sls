
local-laptop-soft:
  pkg.latest:
    - pkgs:
      # Brightness control
      - brightnessctl
      - tuxedo-control-center
      - tuxedo-tomte
      - tuxedo-drivers

# Disable tailscale auto-start - too aggressive
tailscaled.service:
  service.disabled: []

/etc/modprobe.d/iwlwifi.conf:
  file.managed:
    - contents: |
        # /etc/modprobe.d/iwlwifi.conf
        # iwlwifi will dyamically load either iwldvm or iwlmvm depending on the
        # microcode file installed on the system.  When removing iwlwifi, first
        # remove the iwl?vm module and then iwlwifi.
        remove iwlwifi \
        (/sbin/lsmod | grep -o -e ^iwlmvm -e ^iwldvm -e ^iwlwifi | xargs /sbin/rmmod) \
        && /sbin/modprobe -r mac80211
        # Disable powersave bug
        options iwlwifi power_save=0

/etc/NetworkManager/conf.d/wifi-powersave.conf:
  file.managed:
    - contents: |
        # Disable powersave to tune AX211
        [connection]
        wifi.powersave = 2
