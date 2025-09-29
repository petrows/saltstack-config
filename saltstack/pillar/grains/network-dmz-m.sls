# Config for machines in Julia network

# Set ramdisk as off, less memory
tmp_ramdisk: False

upgrades:
  # Do not install upgrades on remote hosts
  auto: False

firewall:
  # Allow connections by default (hosts under firewall already)
  strict_mode: False

ssh:
  # Do not allow password auth for SSH
  allow_pw: False

network:
  cdn: ru
  domain: m.pws
  dns: 10.87.0.1
