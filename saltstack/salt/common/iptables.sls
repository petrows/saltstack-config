# Firewall configuration

{% if pillar.iptables.managed %}

{% set ipf = ['ipv4', 'ipv6'] %}
{% set iptables_persistent = pillar.iptables.persistent|default(True) %}

iptables-pkg:
  pkg.installed:
    - pkgs:
      - iptables
      {% if iptables_persistent %}
      - iptables-persistent
      {% endif %}

{% if not iptables_persistent %}
iptables-pkg-purged:
  pkg.purged:
    - pkgs:
      - iptables-persistent
{% endif %}

{% for f in ipf %}
iptables-default-input-{{ f }}:
  iptables.set_policy:
    - chain: INPUT
    - family: {{ f }}
    - policy: {% if pillar.iptables.strict_mode %}DROP{% else %}ACCEPT{% endif %}
    - save: True

iptables-default-forward-{{ f }}:
  iptables.set_policy:
    - chain: FORWARD
    - family: {{ f }}
    - policy: {% if pillar.iptables.strict_mode %}DROP{% else %}ACCEPT{% endif %}
    - save: True

iptables-port-allow-opened-{{ f }}:
  iptables.append:
    - table: filter
    - family: {{ f }}
    - chain: INPUT
    - jump: ACCEPT
    - connstate: RELATED,ESTABLISHED
    - save: True

# Allow localhost
iptables-port-open-localhost-{{ f }}:
  iptables.append:
    - table: filter
    - family: {{ f }}
    - chain: INPUT
    - jump: ACCEPT
    - source: localhost
    - save: True

# Allow ping and ICMP always
iptables-port-open-icmp-{{ f }}:
  iptables.append:
    - table: filter
    - family: {{ f }}
    - chain: INPUT
    - jump: ACCEPT
    - proto: {% if 'ipv6' == f %}ipv6-icmp{% else %}icmp{% endif %}
    - save: True

# DNS
iptables-port-open-dns-{{ f }}:
  iptables.append:
    - table: filter
    - family: {{ f }}
    - chain: INPUT
    - jump: ACCEPT
    - dport: 53
    - protocol: udp
    - save: True

# SSH port
iptables-port-open-ssh-{{ f }}:
  iptables.append:
    - table: filter
    - family: {{ f }}
    - chain: INPUT
    - jump: ACCEPT
    - dport: {{pillar.ssh.port }}
    - protocol: tcp
    - save: True

# Allowed ports
{% for name, port in pillar.iptables.ports_open.items() %}
iptables-port-open-{{ name }}-{{ f }}:
  iptables.append:
    - table: filter
    - family: {{ f }}
    - chain: INPUT
    - jump: ACCEPT
    - dport: {{ port.dst }}
    - protocol: {{ port.proto | default('tcp') }}
    - save: True
{% endfor %}

# Allowed hosts
{% for name, host in pillar.iptables.hosts_open.items() %}
iptables-host-open-{{ name }}-{{ f }}:
  iptables.append:
    - table: filter
    - family: {{ f }}
    - chain: INPUT
    - jump: ACCEPT
    - source: {{ host.source }}
    - protocol: {{ host.proto | default('tcp') }}
    - save: True
{% endfor %}

# Blocked filters?
{% for name, str in pillar.iptables.strings_block.items() %}
iptables-str-block-{{ name }}-{{ f }}:
  iptables.append:
    - position: 0
    - table: filter
    - family: {{ f }}
    - chain: FORWARD
    - jump: DROP
    - match: string
    - algo: {{ str.algo | default('bm') }}
    - string: {{ str.string }}
    - save: True
{% endfor %}

{% endfor %} # Family

{% else %}
iptables-pkg:
  pkg.purged:
    - pkgs:
      - iptables-persistent
{% endif %}
