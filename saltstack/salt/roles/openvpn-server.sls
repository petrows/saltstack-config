# Role for generic openvpn server

{% set default_if = salt['network.default_route']('inet')[0]['interface'] %}
{% set default_ip = salt['network.ip_addrs'](default_if)[0] %}

openvpn-pkg:
  pkg.installed:
    - pkgs:
      - openvpn
      - iptables
      - iptables-persistent

# Server config(s)

{% for server_id, server in salt['pillar.get']('openvpn-server', {}).items() %}

# Deploy keys

{% for file in ['ca.crt', 'dh.pem', 'private/server.key'] %}
openvpn-file-{{ file }}:
  file.managed:
    - name: /etc/openvpn/server/{{ server_id }}/{{ salt['file.basename'](file) }}
    - source: salt://files/openvpn/{{ server_id }}/pki/{{ file }}
    - makedirs: True
    - mode: 0600
{% endfor %}

{% for file in salt['cp.list_master'](prefix='files/openvpn/'+server_id+'/pki/issued') %}
openvpn-file-{{ file }}:
  file.managed:
    - name: /etc/openvpn/server/{{ server_id }}/{{ salt['file.basename'](file) }}
    - source: salt://{{ file }}
    - makedirs: True
    - mode: 0600
{% endfor %}

# Deply sample user config
openvpn-sample:
  file.managed:
    - name: /etc/openvpn/server/{{ server_id }}/client.ovpn
    - contents: |
        client
        dev {{ server.dev|default('tun') }}
        remote {{ default_ip }}
        resolv-retry infinite
        nobind
        persist-key
        persist-tun
        ca ca.crt
        cert client.crt
        key client.key
        verb 1
        keepalive 10 120
        port {{ server.port|default('443') }}
        proto {{ server.proto|default('udp') }}
        cipher {{ server.cipher|default('AES-256-CBC') }}
    - makedirs: True
    - mode: 0600

# Basic config & service

{% set vpn_device = server.dev|default('tun') %}
{% set vpn_name = server.dev_name|default(vpn_device + '-' + server_id) %}

openvpn-{{ server_id }}-config:
  file.managed:
    - name: /etc/openvpn/server/{{ server_id }}.conf
    - contents: |
        user nobody
        group nogroup
        cipher {{ server.cipher|default('AES-256-CBC') }}
        auth {{ server.auth|default('SHA256') }}
        server {{ server.network|default('10.1.1.0') }} {{ server.netmask|default('255.255.255.0') }}
        port {{ server.port|default('443') }}
        proto {{ server.proto|default('udp') }}
        dev {{ vpn_name }}
        keepalive 10 120
        persist-key
        txqueuelen 2000
        sndbuf 512000
        rcvbuf 512000
        push "sndbuf 512000"
        push "rcvbuf 512000"
{%- if vpn_device == 'tun' %}
        persist-tun
        tun-mtu 1500
{%- endif %}
        ifconfig-pool-persist ipp.txt
        push "redirect-gateway def1 bypass-dhcp"
        push "route {{ server.network|default('10.1.1.0') }} {{ server.netmask|default('255.255.255.0') }}"
        ca /etc/openvpn/server/{{ server_id }}/ca.crt
        dh /etc/openvpn/server/{{ server_id }}/dh.pem
        cert /etc/openvpn/server/{{ server_id }}/server.crt
        key /etc/openvpn/server/{{ server_id }}/server.key

openvpn-server@{{ server_id }}.service:
  service.running:
    - enable: True
    - watch:
      - file: /etc/openvpn/server/{{ server_id }}/*
      - file: /etc/openvpn/server/{{ server_id }}.conf

openvpn-input-{{ server_id }}:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - dport: {{ server.port|default('443') }}
    - comment: "OVPN {{ server_id }}"
    - save: True

openvpn-forward-in-{{ server_id }}:
  iptables.append:
    - table: filter
    - chain: FORWARD
    - jump: ACCEPT
    - in-interface: {{ vpn_name }}
    - comment: "OVPN {{ server_id }}"
    - save: True

openvpn-forward-out-{{ server_id }}:
  iptables.append:
    - table: filter
    - chain: FORWARD
    - jump: ACCEPT
    - out-interface: {{ vpn_name }}
    - comment: "OVPN {{ server_id }}"
    - save: True

{% endfor %}

iptables-masquerade:
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
