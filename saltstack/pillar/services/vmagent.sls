# Config for static local agent for VictoriaMetrics

roles:
  - vmagent
  - node-exporter

vmagent:
  enable: True
  version: 1.107.0
  endpoint: https://vmagent.k8s.pws/api/v1/write
  node_exporters:
    {{ grains.id }}: True
