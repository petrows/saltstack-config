# Common config for Raspberry PI boards used

# Do not upgrade on RPI
upgrades:
  auto: False

# Apt options
apt:
  # RPI requires special repos for ARM64
  url_normal: http://ports.ubuntu.com/ubuntu-ports
  url_security: http://ports.ubuntu.com/ubuntu-ports

# Do not write log data to disk
journald:
  storage: volatile
