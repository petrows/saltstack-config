install_check_mk:
  pkg.installed:
    - sources:
      - check-mk-agent: http://cmk.system.pws/cmk/check_mk/agents/check-mk-agent_1.6.0p10-1_all.deb
