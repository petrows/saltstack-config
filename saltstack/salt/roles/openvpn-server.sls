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

openvpn-{{ server_id }}-config:
  file.managed:
    - name: /etc/openvpn/server/{{ server_id }}.conf
    - contents: |
        user nobody
        group nogroup
        cipher {{ server.cipher|default('AES-256-CBC') }}
        auth {{ server.auth|default('SHA256') }}
        server 10.55.39.0 255.255.255.0
        port {{ server.port|default('443') }}
        proto {{ server.proto|default('udp') }}
        dev {{ server.dev|default('tun') }}
        keepalive 10 120
        persist-key
        ifconfig-pool-persist ipp.txt
        push "redirect-gateway def1 bypass-dhcp"
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

{% endfor %}
