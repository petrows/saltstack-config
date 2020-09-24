roles:
  # Generic role
  - server
  # Monitoring agent and plugins
  - monitoring
  # Redirect local emails to external one
  - mail-relay

# Server will update config on connect
salt_auto_apply: True

# Physical machines should check their logs
check_mk_plugins:
  - mk_logwatch

# Monitoring agent (local site)
check_mk:
  url: http://cmk.system.pws/cmk/check_mk/agents/check-mk-agent_1.6.0p16-1_all.deb
