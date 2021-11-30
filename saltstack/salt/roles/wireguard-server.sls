# Role for generic wireguard server

{% set default_if = salt['network.default_route']('inet')[0]['interface'] %}
{% set default_ip = salt['network.ip_addrs'](default_if)[0] %}

wireguard-pkg:
  pkg.installed:
    - pkgs:
      - wireguard
      - wireguard-tools
      - iptables
      - iptables-persistent

# Server config(s)

{%- for server_id, server in salt['pillar.get']('wireguard-server', {}).items() %}
{%- set peers =  salt['pillar.get']('pws_secrets:wireguard:'+server_id+':client', {}) %}

# Deploy server config

wireguard-{{ server_id }}-config:
  file.managed:
    - name: /etc/wireguard/wg-{{ server_id }}.conf
    - contents: |
        [Interface]
        Address = {{ server.address }}
        ListenPort = {{ server.port }}
        PrivateKey = {{ salt['pillar.get']('pws_secrets:wireguard:'+server_id+':server:private') }}
{%- for peer_id, peer in peers.items() %}
  {%- set peer_ip, peer_netmask = peer.address.split('/') %}
  {%- set peer_ports = peer.ports|default([]) %}
  {%- for port in peer_ports %}
        PreUp = iptables -t nat -A PREROUTING -d {{ default_ip }} -p tcp --dport {{ port }} -j DNAT --to-destination {{ peer_ip }}
        PreUp = iptables -t nat -A PREROUTING -d {{ default_ip }} -p udp --dport {{ port }} -j DNAT --to-destination {{ peer_ip }}
        PostDown = iptables -t nat -D PREROUTING -d {{ default_ip }} -p tcp --dport {{ port }} -j DNAT --to-destination {{ peer_ip }}
        PostDown = iptables -t nat -D PREROUTING -d {{ default_ip }} -p udp --dport {{ port }} -j DNAT --to-destination {{ peer_ip }}
  {%- endfor %}
{%- endfor %}
{%- for peer_id, peer in peers.items() %}
        [Peer]
        PublicKey = {{ peer.public }}
        AllowedIPs = {{ peer.address }}
{% endfor %}

wg-quick@wg-{{ server_id }}.service:
  service.running:
    - enable: True
    - watch:
      - file: /etc/wireguard/wg-{{ server_id }}.conf

wireguard-forward:
  iptables.append:
    - table: filter
    - chain: FORWARD
    - jump: ACCEPT
    - in-interface: wg-{{ server_id }}
    - save: True

{% endfor %}

wireguard-masquerade:
  iptables.append:
    - table: nat
    - chain: POSTROUTING
    - jump: MASQUERADE
    - out-interface: {{ default_if }}
    - save: True

iptables-masquerade-sysctl:
  sysctl.present:
    - name: net.ipv4.ip_forward
    - value: 1
