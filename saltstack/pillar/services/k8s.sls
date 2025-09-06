{% import_yaml 'static.yaml' as static %}

roles:
  - k8s

# Common firewall config
firewall:
  # Enable firewall?
  enabled: False

k8s:
  version: '1.32'
  # Start services as node?
  node: False
  # Support software
  krew:
    version: '0.4.4'
