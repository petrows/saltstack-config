# Config for static local agent for VictoriaMetrics in DMZ

vmagent:
  # Do not process metrics, passive mode
  enable: False
  node_exporter:
    enable: True
  # Do not push metrics, passive mode
  endpoint: ''
