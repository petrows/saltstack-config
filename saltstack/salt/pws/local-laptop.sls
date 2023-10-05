
local-laptop-soft:
  pkg.latest:
    - pkgs:
      # Brightness control
      - light

# Disable tailscale auto-start - too aggressive
tailscaled.service:
  service.disabled: []
