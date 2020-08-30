cmk-server-pkg:
  pkg.installed:
    - sources:
      - {{ pillar.check_mk_server.pkg }}: {{ pillar.check_mk_server.url }}
