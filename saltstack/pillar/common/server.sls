roles:
  # Generic role
  server: True
  # Monitoring agent and plugins
  monitoring: True
  # Redirect local emails to external one
  mail-relay: True

# Server will update config on connect
salt_auto_apply: False

# Physical machines should check their logs
check_mk_plugins:
  netstat.linux: True
  mk_logwatch.py: True

# Monitoring agent (local site)
check_mk_agent:
  install: True

packages:
  sudo: latest

# Default pip3 packages for notifications
packages_pip3:
  telegram-send: True
