roles:
  # Generic role
  - server
  # Monitoring agent and plugins
  - monitoring
  # Redirect local emails to external one
  - mail-relay

# Server will update config on connect
saltstack:
  auto_apply: False

# Physical machines should check their logs
check_mk_plugins:
  - netstat.linux

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
