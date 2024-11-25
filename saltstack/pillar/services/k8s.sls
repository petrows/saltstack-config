{% import_yaml 'static.yaml' as static %}

roles:
  - k8s

k8s:
  version: '1.31'
  # Start services as node?
  node: False
  # Support software
  krew:
    version: '0.4.4'
