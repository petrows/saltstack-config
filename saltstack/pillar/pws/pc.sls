
rslsync:
  data_dir: /home/petro/btsync
  user: petro

# i3 config options
i3:
  bar_font_size: 12
  display: ''
  startup: ''

# At home i have 4 disK
xsession:
  gtk_scale: 1.0

# Some workstation tuning
sysctl:
  # Allow IDE's to watch large projects
  # See: https://youtrack.jetbrains.com/articles/IDEA-A-2/Inotify-Watches-Limit
  fs.inotify.max_user_watches: 524288
