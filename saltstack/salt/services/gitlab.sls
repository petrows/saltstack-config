
gitlab-dir-config:
  file.directory:
    - name: {{ pillar.gitlab.data_dir }}/config
    - makedirs: True
    - user: root
    - group: root
    - mode: 775

gitlab-dir-data:
  file.directory:
    - name: {{ pillar.gitlab.data_dir }}/data
    - makedirs: True
    - user: root
    - group: root
    - mode: 755

gitlab-dir-logs:
  file.directory:
    - name: {{ pillar.gitlab.data_dir }}/logs
    - makedirs: True
    - user: 998
    - group: 998
    - mode: 755

gitlab-compose:
  file.managed:
    - name: /opt/gitlab/docker-compose.yml
    - source: salt://files/gitlab/docker-compose.yml
    - template: jinja
    - makedirs: True
    - user: root
    - group: root
    - mode: 644

gitlab.service:
  file.managed:
    - name: /etc/systemd/system/gitlab.service
    - source: salt://files/docker-compose/systemd.service
    - template: jinja
    - user: root
    - group: root
    - context:
      compose_path: /opt/gitlab/
  service.running:
    - enable: True
    - watch:
      - file: /opt/gitlab/*
