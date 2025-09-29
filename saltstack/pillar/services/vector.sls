# Config for static local agent for VictoriaMetrics

roles:
  - vector

vector:
  enable: True
  endpoint: https://vlog.k8s.pws
  syslog:
    {{ grains.id }}: True

# Vector accepts some external data from decives and logs
firewall:
  rules_filter_input:
    # Open UDP syslog port
    vector-syslog-input: udp dport { 514 } counter accept
