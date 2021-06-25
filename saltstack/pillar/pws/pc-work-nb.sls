# Exteds pc-work.sls

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

# At work i have normal display
xsession:
  gtk_scale: 1.5
  script: |
      xrandr --output eDP-1 --off
      xrandr --output DP-2-3 --mode 3840x2160 --dpi 138 --pos 0x0 --primary
      xrandr --output HDMI-1 --mode 3840x2160 --dpi 138 --pos 3840x0
