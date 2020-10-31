
rslsync:
  data_dir: /home/pgolovachev/btsync
  user: pgolovachev

# i3 config options
i3:
  bar_font_size: 10
  display: |
      # Secondary (left)
      set $mon_1 "DP-4"
      # Primary (center)
      set $mon_2 "DP-2"
      # Secondary (right)
      set $mon_3 "DP-0"
      # Workspaces
      workspace $ws1 output $mon_1
      workspace $ws2 output $mon_2
      workspace $ws3 output $mon_3
  startup: |
      exec --no-startup-id i3-msg 'workspace $ws3; append_layout ~/.config/i3/layout-work-w3.json;'
      exec --no-startup-id google-chrome
      exec --no-startup-id teams
      exec --no-startup-id evolution
      # Klipboard manager
      exec --no-startup-id klipper

# At work i have normal display
xsession:
  gtk_scale: 1.0
