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
