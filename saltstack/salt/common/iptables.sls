# Firewall configuration

iptables-pkg:
  pkg.installed:
    - pkgs:
      - iptables
      - iptables-persistent

iptables-default-input:
  iptables.set_policy:
    - chain: INPUT
    - family: ipv4
    - policy: {% if pillar.iptables.strict_mode %}DROP{% else %}ACCEPT{% endif %}
    - save: True

iptables-default-forward:
  iptables.set_policy:
    - chain: FORWARD
    - family: ipv4
    - policy: {% if pillar.iptables.strict_mode %}DROP{% else %}ACCEPT{% endif %}
    - save: True

iptables-port-allow-opened:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - connstate: RELATED,ESTABLISHED
    - save: True

# Allow localhost
iptables-port-open-localhost:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - source: localhost
    - save: True

# Allow ping?
{% if pillar.iptables.allow_ping %}
iptables-port-open-ping:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - proto: icmp
    - icmp-type: echo-request
    - save: True
{% endif %}

# DNS
iptables-port-open-dns:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - dport: 53
    - protocol: udp
    - save: True

# SSH port
iptables-port-open-ssh:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - dport: {{pillar.ssh.port }}
    - protocol: tcp
    - save: True

# Allowed ports
{% for name, port in pillar.iptables.ports_open.items() %}
iptables-port-open-{{ name }}:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - dport: {{ port.dst }}
    - protocol: {{ port.proto | default('tcp') }}
    - save: True
{% endfor %}

# Allowed hosts
{% for name, host in pillar.iptables.hosts_open.items() %}
iptables-host-open-{{ name }}:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - source: {{ host.source }}
    - protocol: {{ host.proto | default('tcp') }}
    - save: True
{% endfor %}

# Blocked filters?
{% for name, str in pillar.iptables.strings_block.items() %}
iptables-str-block-{{ name }}:
  iptables.append:
    - position: 0
    - table: filter
    - chain: FORWARD
    - jump: DROP
    - match: string
    - algo: {{ str.algo | default('bm') }}
    - string: {{ str.string }}
    - save: True
{% endfor %}
