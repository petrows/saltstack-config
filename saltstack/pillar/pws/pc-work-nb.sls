rslsync:
  instances:
    petro:
      data_dir: /home/pgolovachev/btsync
      user: pgolovachev

# i3 config options
i3:
  display: |
      # Display config
      # Left
      set $mon_1 "DP-2-3"
      # Right
      set $mon_2 "HDMI-1"
      # Workspaces
      workspace $ws1 output $mon_1
      workspace $ws2 output $mon_2
  startup: |
      for_window [class="Spotify"] move to workspace $ws2
      exec --no-startup-id i3-msg 'workspace $ws2; append_layout ~/.config/i3/layout-work-nb-w2.json;'
      exec --no-startup-id google-chrome
      exec --no-startup-id teams
      exec --no-startup-id evolution
      exec --no-startup-id telegram-desktop
      exec --no-startup-id nagstamon

# At work i have normal display
xsession:
  gtk_scale: 1.5
  script: |
      xrandr --output eDP-1 --off
      xrandr --output DP-2-3 --mode 3840x2160 --dpi 138 --pos 0x0 --primary
      xrandr --output HDMI-1 --mode 3840x2160 --dpi 138 --pos 3840x0
