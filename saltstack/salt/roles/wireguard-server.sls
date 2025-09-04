# Role for generic wireguard server

{% set firewall_enable =  salt['pillar.get']('wireguard:iptables', True) %}

{% set default_if = salt['network.default_route']('inet')[0]['interface'] %}
{% set default_ip = salt['network.ip_addrs'](default_if)[0] %}
{% set ns = namespace (cfg = {'awg': False}) %}

{% for server_id, server in salt['pillar.get']('wireguard-server', {}).items() %}
{% if server.get('type', 'wg') == 'awg' %}
{% set _ = ns.cfg.update({'awg':True}) %}
{% endif %}
{% endfor %}

wireguard-pkg:
  pkg.installed:
    - pkgs:
      - wireguard
      - wireguard-tools
      - iptables

# Install Amneziawg?
{% if ns.cfg.awg or salt['pillar.get']('wireguard:awg', None) %}
amnezia-repo:
  pkgrepo.managed:
    - name: deb https://ppa.launchpadcontent.net/amnezia/ppa/ubuntu {{ grains.oscodename }} main
    - file: /etc/apt/sources.list.d/amnezia.list
    - clean_file: True
    - keyid: 75C9DD72C799870E310542E24166F2C257290828
    - keyserver: keyserver.ubuntu.com
amnezia-src-repo:
  pkgrepo.managed:
    - name: deb-src https://ppa.launchpadcontent.net/amnezia/ppa/ubuntu {{ grains.oscodename }} main
    - file: /etc/apt/sources.list.d/amnezia-src.list
    - clean_file: True
    - keyid: 75C9DD72C799870E310542E24166F2C257290828
    - keyserver: keyserver.ubuntu.com
amnezia-pkg:
  pkg.installed:
    - pkgs:
      - amneziawg
{% endif %}

# Firewall config
/etc/nftables.d/wg-server.nft:
  file.managed:
    - makedirs: True
    - contents: |
        {%- if firewall_enable %}
        table inet filter {
            chain input {
                {% for server_id, server in salt['pillar.get']('wireguard-server', {}).items() %}
                {%- if server.get('port', False) %}
                # Open incoming port for (A)WG {{ server_id }}
                udp dport {{ server.port }} counter accept comment "(A)WG {{ server_id }}"
                {%- endif %}
                {%- endfor %}
            }
            chain forward {
                {% for server_id, server in salt['pillar.get']('wireguard-server', {}).items() %}
                {% set server_type = server.get('type', 'wg') %}
                # Allow forwarding for {{ server_type|upper }} {{ server_id }}
                iifname "{{ server_type }}-{{ server_id }}" counter accept comment "{{ server_type|upper }} {{ server_id }}"
                oifname "{{ server_type }}-{{ server_id }}" counter accept comment "{{ server_type|upper }} {{ server_id }}"
                {%- endfor %}
            }
        }
        table inet nat {
            chain postrouting {
                oifname "{{ default_if }}" counter masquerade comment "AWG Masquerade"
            }
        }
        {%- endif %}

# Server config(s)


{% for server_id, server in salt['pillar.get']('wireguard-server', {}).items() %}
{% set server_type = server.get('type', 'wg') %}
{% set server_secrets = salt['pillar.get']('pws_secrets:wireguard:'+server_id+':server', {}) %}
{% set peers = salt['pillar.get']('pws_secrets:wireguard:'+server_id+':client', {}) %}
{% if server_type == 'wg' %}
{% set server_conf_path = '/etc/wireguard/wg-' + server_id + '.conf' %}
# Cleanup "opposite"
{{ '/etc/amnezia/amneziawg/awg-' + server_id + '.conf'}}:
  file.absent: []
{% elif server_type == 'awg' %}
{% set server_conf_path = '/etc/amnezia/amneziawg/awg-' + server_id + '.conf' %}
# Cleanup "opposite"
{{ '/etc/wireguard/wg-' + server_id + '.conf'}}:
  file.absent: []
{% endif %}

# Deploy server config

{{ server_conf_path }}:
  file.managed:
    - contents: |
        [Interface]
        Address = {{ server.address }}
        {% if server.get('port', False) %}ListenPort = {{ server.port }}{% endif %}
        {% if server_secrets.get('server_dns') %}PostUp = resolvectl dns %i {{server_secrets.server_dns.dns}}; resolvectl domain %i ~{{ server_secrets.server_dns.domain | join(' ~') }}{% endif %}
        PrivateKey = {{ server_secrets.private }}
        {% if server.get('fwmark', False) %}FwMark = {{ server.fwmark }}{% endif %}
{%- if server.get('autorun', True) %}
        # PreUp & PostUp delay, to fix config changes not applied
        PreUp = sleep 1
        PostDown = sleep 1
{%- endif %}
{%- if server_type == 'awg' %}
        {%- for k, v in server_secrets.awg.items() %}
        {{ k }} = {{ v }}
        {%- endfor %}
{%- endif %}
{%- for peer_id, peer in peers.items() %}
  {%- set peer_ip, peer_netmask = peer.address.split('/') %}
  {%- set peer_ports = peer.ports|default([]) %}
  {%- for port in peer_ports %}
        PreUp = iptables-nft -t nat -A PREROUTING -d {{ default_ip }} -p tcp --dport {{ port }} -j DNAT --to-destination {{ peer_ip }}
        PreUp = iptables-nft -t nat -A PREROUTING -d {{ default_ip }} -p udp --dport {{ port }} -j DNAT --to-destination {{ peer_ip }}
        PostDown = iptables-nft -t nat -D PREROUTING -d {{ default_ip }} -p tcp --dport {{ port }} -j DNAT --to-destination {{ peer_ip }}
        PostDown = iptables-nft -t nat -D PREROUTING -d {{ default_ip }} -p udp --dport {{ port }} -j DNAT --to-destination {{ peer_ip }}
  {%- endfor %}
{%- endfor %}
{%- for peer_id, peer in peers.items() %}
        # {{ peer_id }}: {{ peer.comment | default('') }}
        [Peer]
        {% if peer.get('endpoint', False) %}
        Endpoint = {{ peer.endpoint }}
        PersistentKeepalive = 20
        {% endif %}
        PublicKey = {{ peer.public }}
        AllowedIPs = {{ peer.address }}
{% endfor %}

{% if server.get('autorun', True) %}
{{ server_type }}-quick@{{ server_type }}-{{ server_id }}.service:
  service.running:
    - enable: True
    - full_restart: True
    - watch:
      - file: {{ server_conf_path }}
{% endif %}
{% endfor %} # Servers

iptables-masquerade-sysctl:
  sysctl.present:
    - name: net.ipv4.ip_forward
    - value: 1
