
rslsync:
  instances:
    petro:
      data_dir: /home/petro/btsync
      user: petro

# i3 config options
i3:
  bar_font_size: 12
  display: |
      # Primary (left)
      set $mon_1 "DP-2"
      # Secondary (right)
      set $mon_2 "DP-4"
      # Workspaces
      workspace $ws1 output $mon_1
      workspace $ws2 output $mon_2
  startup: |
      exec --no-startup-id i3-msg 'workspace $ws2; append_layout ~/.config/i3/layout-home-w2.json;'
      exec --no-startup-id i3-msg 'workspace $ws1; append_layout ~/.config/i3/layout-work-nb-w1.json;'
      # exec --no-startup-id firefox
      exec --no-startup-id telegram-desktop
      # exec --no-startup-id spotify
      exec --no-startup-id nagstamon
  temp_read: /sys/devices/platform/coretemp.0/hwmon/hwmon2/temp1_input

# At home i have 4 disK
xsession:
  gtk_scale: 1.5
  script: |
      xrandr --output DP-2 --mode 3840x2160 --dpi 138 --pos 0x0 --primary
      xrandr --output DP-4 --mode 3840x2160 --dpi 138 --pos 3840x0
