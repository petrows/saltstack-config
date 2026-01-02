# Config for static local agent for VictoriaMetrics

roles:
  - vector

vector:
  enable: True
  endpoint: https://10.80.0.14:5858
  data_dir: /srv/vector
  max_buffer_disk_size: {{ 1 * 1024 * 1024 * 1024 }}
  syslog:
    {{ grains.id }}: True

# Vector accepts some external data from decives and logs
firewall:
  rules_filter_input:
    # Open UDP syslog port
    vector-syslog-input: udp dport { 514 } counter accept
