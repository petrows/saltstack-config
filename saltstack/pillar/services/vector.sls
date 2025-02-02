# Config for static local agent for VictoriaMetrics

roles:
  - vector

vector:
  enable: True
  endpoint: https://vlog.k8s.pws/insert/elasticsearch
  syslog:
    {{ grains.id }}: True
