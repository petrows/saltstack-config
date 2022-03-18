roles:
  - docker
  - nginx

rslsync:
  data_dir: /home/petro/btsync
  user: petro

# I have 4K displays
xsession:
  gtk_scale: 1.0

# Some workstation tuning
sysctl:
  # Allow IDE's to watch large projects
  # See: https://youtrack.jetbrains.com/articles/IDEA-A-2/Inotify-Watches-Limit
  fs.inotify.max_user_watches: 524288

# Define default apps for workspaces
i3:
  apps_ws:
    - class: Spotify
      ws: 2
    - class: ^TelegramDesktop$
      ws: 2
    - class: ^Code$
      ws: 1
