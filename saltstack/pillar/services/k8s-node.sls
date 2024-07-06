{% import_yaml 'static.yaml' as static %}

kernel-modules:
  br_netfilter: True

k8s:
  # Start services as node?
  node: True

# Disable iptables management
iptables:
  managed: False
