
rslsync:
  data_dir: /home/petro/btsync
  user: petro

# i3 config options
i3:
  display: |
      # Primary (left)
      set $mon_1 "DP-2"
      # Secondary (right)
      set $mon_2 "DP-4"
      # Workspaces
      workspace $ws1 output $mon_1
      workspace $ws2 output $mon_2
  startup: |
      for_window [class="Spotify"] move to workspace $ws2
      exec --no-startup-id i3-msg 'workspace $ws2; append_layout ~/.config/i3/layout-home-w2.json;'
      exec --no-startup-id google-chrome
      exec --no-startup-id Telegram/Telegram
      # exec --no-startup-id spotify
      exec --no-startup-id nagstamon
