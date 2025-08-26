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
