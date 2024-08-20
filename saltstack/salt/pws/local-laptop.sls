
local-laptop-soft:
  pkg.latest:
    - pkgs:
      # Brightness control
      - light

# Disable tailscale auto-start - too aggressive
tailscaled.service:
  service.disabled: []

{% set block_networks_from_of_lan = ['192.168.98.0/24', '10.80.0.0/16', '172.16.0.0/16'] %}

{% for net in block_networks_from_of_lan %}
# Block rslsync to spam into LAN
iptables-block-of-lan-{{ loop.index }}-tcp:
  iptables.append:
    - table: filter
    - chain: OUTPUT
    - jump: REJECT
    - source: 192.168.0.0/16
    - destination: {{ net }}
    - proto: tcp
    - save: True

iptables-block-of-lan-{{ loop.index }}-udp:
  iptables.append:
    - table: filter
    - chain: OUTPUT
    - jump: REJECT
    - source: 192.168.0.0/16
    - destination: {{ net }}
    - proto: udp
    - save: True
{% endfor %}
