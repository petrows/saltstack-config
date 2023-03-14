dante-pkg:
  pkg.installed:
    - pkgs:
      - dante-server

/etc/danted.conf:
  file.managed:
    - contents: |
        logoutput: stderr
        # debug: 2
        internal: {{ pillar.dante.if | default('0.0.0.0') }} port = {{ pillar.dante.port }}
        external: {{ pillar.dante.if_external }}
        user.notprivileged: nobody
        clientmethod: none
        socksmethod: none
        # client
        client pass {
          from: 0.0.0.0/0 to: 0.0.0.0/0
          log: error # connect disconnect
        }
        # generic pass statement - bind/outgoing traffic
        socks pass {
          from: 0.0.0.0/0 to: 0.0.0.0/0
          command: bind connect udpassociate
          log: error # connect disconnect iooperation
        }
        # generic pass statement for incoming connections/packets
        socks pass {
          from: 0.0.0.0/0 to: 0.0.0.0/0
          command: bindreply udpreply
          log: error # connect disconnect iooperation
        }
    - require:
      - pkg: dante-pkg

danted.service:
  service.running:
    - enable: True
    - watch:
      - file: /etc/danted.conf
      - pkg: dante-pkg
