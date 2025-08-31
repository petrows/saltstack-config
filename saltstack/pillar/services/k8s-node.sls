{% import_yaml 'static.yaml' as static %}
{% set is_ct = grains.get('virtual:container') %}

roles:
  - k8s-node
{% if not is_ct %}
  - k8s-node-ct
{% endif %}

# No swap allowed
swap_size_mb: 0

k8s:
  # Start services as node?
  node: True
  {% if not is_ct %}
  ct: True
  {% endif %}

# VM only
{% if not is_ct %}

kernel-modules:
  br_netfilter: True

# Static network config: use root NS
network:
  netplan:
    network:
      version: 2
      renderer: networkd
      ethernets:
        eth-lan:
          match:
            name: ens*
          set-name: eth-lan
          # ipv4: auto
          dhcp4: yes
          # Do not use DNS from dhcp
          dhcp4-overrides:
            use-dns: no
          # Enforce primary one
          nameservers:
            addresses: [10.80.0.1]
          # Disable ipv6
          link-local: [ ipv4 ]
{% endif %}
