{% import_yaml 'static.yaml' as static %}

roles:
  - k8s

# Common firewall config
firewall:
  # Enable firewall?
  enabled: True
  # Require legacy mode, as iptables-nft is not fully compatible with nftables
  legacy_mode: True

k8s:
  version: '1.34'
  # Start services as node?
  node: False
  # Support software
  krew:
    version: '0.4.4'
