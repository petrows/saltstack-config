{% import_yaml 'static.yaml' as static %}

roles:
  - k8s
  - docker

k8s:
  version: '1.30'
  # Start services as node?
  node: False
