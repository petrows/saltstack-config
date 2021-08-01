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
check_mk:
  url: https://cmk.system.pws/cmk/check_mk/agents/check-mk-agent_2.0.0p6-1_all.deb

packages:
  - sudo

# Default pip3 packages for notifications
packages_pip3:
  - telegram-send
