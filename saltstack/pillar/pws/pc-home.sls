
rslsync:
  instances:
    petro:
      data_dir: /home/petro/btsync
      user: petro

# i3 config options
i3:
  bar_font_size: 12
  display_config_id: petro-pc
  startup: |
      # exec --no-startup-id firefox
      exec --no-startup-id telegram-desktop
      # exec --no-startup-id spotify
      exec --no-startup-id nagstamon
      exec --no-startup-id bash -c 'sleep 5; firefox'
      exec --no-startup-id doublecmd --no-splash
      exec --no-startup-id konsole
      exec --no-startup-id keepassxc
  temp_read: /sys/devices/platform/coretemp.0/hwmon/hwmon2/temp1_input

# At home i have 4 disK
xsession:
  gtk_scale: 1.5
  script: |
      xrandr --output DP-2 --mode 3840x2160 --dpi 138 --pos 0x0 --primary
      xrandr --output DP-4 --mode 3840x2160 --dpi 138 --pos 3840x0
