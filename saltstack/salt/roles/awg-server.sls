# Role for generic wireguard server

{% set iptables_enable =  salt['pillar.get']('wireguard:iptables', True) %}
{% set iptables_persistent =  salt['pillar.get']('wireguard:iptables_persistent', True) %}

{% set default_if = salt['network.default_route']('inet')[0]['interface'] %}
{% set default_ip = salt['network.ip_addrs'](default_if)[0] %}

# awg-pkg:
#   pkg.installed:
#     - pkgs:
#       - iptables-persistent

awg-repo:
  pkgrepo.managed:
    - name: deb https://ppa.launchpadcontent.net/amnezia/ppa/ubuntu {{ grains.oscodename }} main
    - file: /etc/apt/sources.list.d/amnezia.list
    - clean_file: True
    - keyid: 75C9DD72C799870E310542E24166F2C257290828
    - keyserver: keyserver.ubuntu.com
awg-src-repo:
  pkgrepo.managed:
    - name: deb-src https://ppa.launchpadcontent.net/amnezia/ppa/ubuntu {{ grains.oscodename }} main
    - file: /etc/apt/sources.list.d/amnezia-src.list
    - clean_file: True
    - keyid: 75C9DD72C799870E310542E24166F2C257290828
    - keyserver: keyserver.ubuntu.com
awg-pkg:
  pkg.installed:
    - pkgs:
      - amneziawg

{% for server_id, server in salt['pillar.get']('awg-server', {}).items() %}

{% if server.get('autorun', True) %}
{{ server_type }}-quick@{{ server_type }}-{{ server_id }}.service:
  service.running:
    - enable: True
    - full_restart: True
    - watch:
      - file: {{ server_conf_path }}
{% endif %}

# Create iptables rules?
{% if iptables_enable %}

# If server defines port - open it
{% if server.get('port', False) %}
wireguard-input-{{ server_id }}:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - protocol: udp
    - dport: {{ server.port }}
    - comment: "WG {{ server_id }}"
    - save: True
{%- endif %}

wireguard-forward-in-{{ server_id }}:
  iptables.append:
    - table: filter
    - chain: FORWARD
    - jump: ACCEPT
    - in-interface: {{ server_type }}-{{ server_id }}
    - comment: "WG {{ server_id }}"
    - save: True

wireguard-forward-out-{{ server_id }}:
  iptables.append:
    - table: filter
    - chain: FORWARD
    - jump: ACCEPT
    - out-interface: {{ server_type }}-{{ server_id }}
    - comment: "WG {{ server_id }}"
    - save: True

{% endif %} # iptables option

{% endfor %} # Servers

{% if iptables_enable %}
wireguard-masquerade:
  iptables.append:
    - table: nat
    - chain: POSTROUTING
    - jump: MASQUERADE
    - out-interface: {{ default_if }}
    - save: True
{% endif %}

iptables-masquerade-sysctl:
  sysctl.present:
    - name: net.ipv4.ip_forward
    - value: 1
