{% import_yaml 'static.yaml' as static %}

kernel-modules:
  br_netfilter: True

# No swap allowed
swap_size_mb: 0

k8s:
  # Start services as node?
  node: True

# Disable iptables management
iptables:
  managed: False

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
          nameservers:
            addresses: [10.80.0.1]
