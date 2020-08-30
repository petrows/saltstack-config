
cmk-server-dir-config:
  file.directory:
    - name: {{ pillar.check_mk_server.data_dir }}
    - makedirs: True
    - user: 1000
    - group: 1000
    - mode: 775

cmk-server-compose:
  file.managed:
    - name: /opt/cmk-server/docker-compose.yml
    - source: salt://files/cmk-server/docker-compose.yml
    - template: jinja
    - makedirs: True
    - user: root
    - group: root
    - mode: 644

cmk-server.service:
  file.managed:
    - name: /etc/systemd/system/cmk-server.service
    - source: salt://files/docker-compose/systemd.service
    - template: jinja
    - user: root
    - group: root
    - context:
      compose_path: /opt/cmk-server/
  service.running:
    - enable: True
    - watch:
      - file: /opt/cmk-server/*
