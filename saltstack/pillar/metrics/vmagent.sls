# Config for static local agent for VictoriaMetrics

roles:
  - vmagent
  - node-exporter

vmagent:
  enable: True
  version: 1.107.0
  endpoint: https://10.80.0.14:5959/
  node_exporters:
    {{ grains.id }}: {}
