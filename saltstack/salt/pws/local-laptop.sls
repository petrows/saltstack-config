
local-laptop-soft:
  pkg.latest:
    - pkgs:
      # Brightness control
      - brightnessctl
      - tuxedo-control-center
      - tuxedo-tomte
      - tuxedo-drivers

# Disable tailscale auto-start - too aggressive
tailscaled.service:
  service.disabled: []
