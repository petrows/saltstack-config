# Special network for k8s nodes

firewall:
  # Allow connections by default (hosts under firewall already)
  strict_mode: False

network:
  # k8s nodes only uses plain .pws domain
  domain: pws
