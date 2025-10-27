rslsync:
  instances:
    petro:
      data_dir: /home/pgolovachev/btsync
      user: pgolovachev

# i3 config options
i3:
  bar_font_size: 10
  display_config_id: work-pc
  startup: |
      exec --no-startup-id bash -c 'is-working-hours && sleep 5 && ms-teams'
      exec --no-startup-id bash -c 'is-working-hours && xkb-teams-activity'
      exec --no-startup-id bash -c 'is-working-hours && evolution'
      exec --no-startup-id bash -c 'tuxedo-control-center --tray'

# At work i have 4K display
xsession:
  gtk_scale: 1.5
  script: |
      # xrandr --output DP-4 --mode 3840x2160 --dpi 138 --pos 0x0 --primary
      # xrandr --output DP-2 --mode 3840x2160 --dpi 138 --right-of DP-4
      # xrandr --output DP-1-1 --mode 3840x2160 --dpi 138 --pos 0x0 --primary
      # xrandr --output DP-2 --mode 3840x2160 --dpi 138 --right-of DP-1-1

# PHP development
php:
  user: pgolovachev
