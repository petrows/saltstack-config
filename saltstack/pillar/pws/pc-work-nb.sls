# Exteds pc-work.sls

# i3 config options
i3:
  display_config_id: work-nb
  temp_read: /sys/devices/platform/coretemp.0/hwmon/hwmon7/temp1_input
  # Enable compton?
  composite: False

# At work i have normal display
xsession:
  gtk_scale: 1.5
  script: |
      # Configure backlight
      # Minimal value
      light -N 1
      light -S 10
      # Detect and set screen layout
      . /usr/local/sbin/setscreen-auto

kernel-modules:
  nct6775: False

# Swap file for hibernate or sleep
swap_size_mb: 4096

# Firewall rules to block unwanted traffic
{% set block_networks_from_of_lan = ['192.168.98.0/24', '10.80.0.0/16', '172.16.0.0/16'] %}
firewall:
  rules_filter_output:
    {% for net in block_networks_from_of_lan %}
      # Block rslsync to spam into LAN
      iptables-block-of-lan-{{ loop.index }}-tcp: ip saddr 192.168.0.0/16 ip daddr {{ net }} counter reject with icmp type admin-prohibited
    {% endfor %}
