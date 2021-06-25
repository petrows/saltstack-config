rslsync:
  instances:
    petro:
      data_dir: /home/pgolovachev/btsync
      user: pgolovachev

# i3 config options
i3:
  bar_font_size: 10
  display: |
      # Primary (left)
      set $mon_1 "DP-4"
      # Secondary (right)
      set $mon_2 "DP-2"
      # Workspaces
      workspace $ws1 output $mon_1
      workspace $ws2 output $mon_2
  startup: |
      for_window [class="Spotify"] move to workspace $ws2
      exec --no-startup-id i3-msg 'workspace $ws2; append_layout ~/.config/i3/layout-work-nb-w2.json;'
      exec --no-startup-id i3-msg 'workspace $ws1; append_layout ~/.config/i3/layout-work-nb-w1.json;'
      exec --no-startup-id google-chrome
      exec --no-startup-id teams
      exec --no-startup-id evolution
      exec --no-startup-id telegram-desktop
      exec --no-startup-id doublecmd
      exec --no-startup-id code
      exec --no-startup-id konsole
      exec --no-startup-id nagstamon

# At work i have 4Л display
xsession:
  gtk_scale: 1.5
  script: |
      xrandr --output DP-4 --mode 3840x2160 --dpi 138 --pos 0x0 --primary
      xrandr --output DP-2 --mode 3840x2160 --dpi 138 --right-of DP-4
