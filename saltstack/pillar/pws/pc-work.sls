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
      # exec --no-startup-id firefox
      exec --no-startup-id bash -c 'is-working-hours && google-chrome --app=https://teams.microsoft.com'
      exec --no-startup-id bash -c 'is-working-hours && evolution'
      exec --no-startup-id telegram-desktop
      exec --no-startup-id doublecmd --no-splash
      exec --no-startup-id code
      exec --no-startup-id konsole
      exec --no-startup-id konsole
      exec --no-startup-id keepassxc
      exec --no-startup-id nagstamon
      exec --no-startup-id bash -c 'sleep 5; is-working-hours && ~/bin/cinemo-vpn'
      exec --no-startup-id bash -c 'sleep 5; firefox'

# At work i have 4K display
xsession:
  gtk_scale: 1.5
  script: |
      xrandr --output DP-4 --mode 3840x2160 --dpi 138 --pos 0x0 --primary
      xrandr --output DP-2 --mode 3840x2160 --dpi 138 --right-of DP-4
