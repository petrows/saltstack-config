
local-laptop-soft:
  pkg.latest:
    - pkgs:
      # VPN
      - wireguard-tools
      # Tuxedo
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

# Interfaces names
/etc/systemd/network/10-interface-wlan.link:
  file.managed:
    - contents: |
        # Wlan onboard
        [Match]
        MACAddress=dc:97:ba:72:16:db
        [Link]
        Name=wlan

/etc/systemd/network/10-interface-onboard.link:
  file.managed:
    - contents: |
        # Oboard 1gbe lan uplink
        [Match]
        MACAddress=b0:25:aa:6b:7a:b3
        [Link]
        Name=eth-onb

/etc/systemd/network/10-interface-dock-w.link:
  file.managed:
    - contents: |
        # Dock station (W)
        [Match]
        MACAddress=04:bf:1b:4d:f8:35
        [Link]
        Name=eth-dw

/etc/systemd/network/10-interface-dock-h.link:
  file.managed:
    - contents: |
        # Dock station (H)
        [Match]
        MACAddress=60:5b:30:1e:02:11
        [Link]
        Name=eth-dh

/etc/systemd/network/10-interface-dock-m.link:
  file.managed:
    - contents: |
        # Dock station (Mobile)
        [Match]
        MACAddress=a0:ce:c8:f9:38:bb
        [Link]
        Name=eth-dm
