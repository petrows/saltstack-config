
nextcloud-rootdir:
  file.directory:
    - name:  /opt/nextcloud
    - makedirs: True
    - user:  root
    - group:  root
    - mode:  755

{% for dir in pillar.get('nextcloud:dirs', []) %}
nextcloud-dir-{{ dir }}:
  file.directory:
    - name:  {{ dir }}
    - makedirs: True
    - user:  {{ pillar.static.uids.www-data }}
    - group:  {{ pillar.static.uids.www-data }}
    - mode:  755
{% endfor %}

nextcloud-compose:
  file.managed:
    - name: /opt/nextcloud/docker-compose.yml
    - source: salt://files/nextcloud/docker-compose.yml
    - template: jinja
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
