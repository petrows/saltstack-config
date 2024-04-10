# Config for machines in Julia network

upgrades:
  # Do not install upgrades on remote hosts
  auto: False

iptables:
  # Allow connections by default (hosts under firewall already)
  strict_mode: False

ssh:
  # Do not allow password auth for SSH
  allow_pw: False

network:
  domain: j.pws
