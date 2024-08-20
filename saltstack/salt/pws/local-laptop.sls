
local-laptop-soft:
  pkg.latest:
    - pkgs:
      # Brightness control
      - light

# Disable tailscale auto-start - too aggressive
tailscaled.service:
  service.disabled: []

# Block rslsync to spam into LAN
iptables-block-rslsync-lan-tcp:
  iptables.append:
    - table: filter
    - chain: OUTPUT
    - jump: DROP
    - destination: 192.168.0.0/24
    - dport: 40107
    - proto: tcp
    - save: True
    - comment: "Block rslsync to LAN (tcp)"

iptables-block-rslsync-lan-udp:
  iptables.append:
    - table: filter
    - chain: OUTPUT
    - jump: DROP
    - destination: 192.168.0.0/24
    - dport: 40107
    - proto: udp
    - save: True
    - comment: "Block rslsync to LAN (udp)"
