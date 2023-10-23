roles:
  # Generic role
  - server
  # Monitoring agent and plugins
  - monitoring
  # Redirect local emails to external one
  - mail-relay

# Server will update config on connect
salt_auto_apply: False

# Physical machines should check their logs
check_mk_plugins:
  - netstat.linux
  - mk_logwatch.py

# Monitoring agent (local site)
check_mk_agent:
  install: True
  ssh: False

packages:
  - sudo
  # Required to build some pip packages
  - pkg-config
  # Requered by pip systemd
  - libsystemd-dev

# Default pip3 packages for notifications
packages_pip3:
  - telegram-send
  - docker
  - systemd-python
  - dnspython
