# Config for machines in w network

firewall:
  # Allow connections by default (hosts under firewall already)
  strict_mode: False

network:
  # THis host runs k8s nodes only so it uses plain .pws domain
  domain: pws
  dns: 10.88.0.1
