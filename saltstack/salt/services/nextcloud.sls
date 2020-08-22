{% for dir in salt.pillar.get('nextcloud:dirs', []) %}
nextcloud-dir-{{ dir }}:
  file.directory:
    - name: {{ dir }}
    - makedirs: True
    - user: {{ salt.pillar.get('static:uids:www-data') }}
    - group: {{ salt.pillar.get('static:uids:www-data') }}
    - mode: 755
{% endfor %}

nextcloud-dir-db:
  file.directory:
    - name: {{ pillar.nextcloud.data_dir }}/db
    - makedirs: True
    - user: 999
    - group: 999
    - mode: 755

nextcloud-compose:
  file.managed:
    - name: /opt/nextcloud/docker-compose.yml
    - source: salt://files/nextcloud/docker-compose.yml
    - template: jinja
    - makedirs: True
    - user: root
    - group: root
    - mode: 644

nextcloud.service:
  file.managed:
    - name: /etc/systemd/system/nextcloud.service
    - source: salt://files/docker-compose/systemd.service
    - template: jinja
    - user: root
    - group: root
    - context:
      compose_path: /opt/nextcloud/
  service.running:
    - enable: True
    - watch:
      - file: /opt/nextcloud/*
