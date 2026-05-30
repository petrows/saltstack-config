# Config for machines in Julia network

# Set ramdisk as default, to save flash resource
tmp_ramdisk: True

firewall:
  # Allow connections by default (hosts under firewall already)
  strict_mode: False

ssh:
  # Do not allow password auth for SSH
  allow_pw: False

network:
  cdn: ru
  domain: j.pws
  dns: 10.82.0.1
