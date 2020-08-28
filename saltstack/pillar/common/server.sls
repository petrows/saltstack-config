roles:
  # Generic role
  - server
  # Monitoring agent and plugins
  - monitoring
  # Redirect local emails to external one
  - mail-relay

# Monitoring agent (local site)
check_mk:
  url: http://cmk.system.pws/cmk/check_mk/agents/check-mk-agent_1.6.0p10-1_all.deb
