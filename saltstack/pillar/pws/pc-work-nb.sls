# Exteds pc-work.sls

# i3 config options
i3:
  display: |
      # Display config
      # Left
      set $mon_1 "DP-3-1"
      # Right
      set $mon_2 "DP-3-2"
      # Workspaces
      workspace $ws1 output $mon_1
      workspace $ws2 output $mon_2
  temp_read: /sys/devices/platform/coretemp.0/hwmon/hwmon3/temp1_input

# At work i have normal display
xsession:
  gtk_scale: 1.5
  script: ''
