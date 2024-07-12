# Exteds pc-work.sls

# i3 config options
i3:
  display_config_id: work-nb
  temp_read: /sys/devices/platform/coretemp.0/hwmon/hwmon6/temp1_input
  # Enable compton?
  composite: False

# At work i have normal display
xsession:
  gtk_scale: 1.5
  script: |
      # Configure backlight
      # Minimal value
      light -N 1
      light -S 10
      # Detect lid state and decide - what to use
      if grep -q closed /proc/acpi/button/lid/LID0/state; then
        # Closed lid
        /usr/local/sbin/setscreen-double
      else
        # Open lid
        export GDK_DPI_SCALE=1.2
        /usr/local/sbin/setscreen-onboard
      fi

kernel-modules:
  nct6775: False
