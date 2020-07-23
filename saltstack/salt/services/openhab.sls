
openhab-rootdir:
  file.directory:
    - name:  /opt/openhab
    - makedirs: True
    - user:  root
    - group:  root
    - mode:  755

{% for dir in pillar.get('openhab:dirs', []) %}
openhab-dir-{{ dir }}:
  file.directory:
    - name:  {{ dir }}
    - makedirs: True
    - user:  {{ pillar.static.uids.master }}
    - group:  {{ pillar.static.uids.master }}
    - mode:  755
{% endfor %}

openhab-compose:
  file.managed:
    - name: /opt/openhab/docker-compose.yml
    - source: salt://files/openhab/docker-compose.yml
    - template: jinja
    - user: root
    - group: root
    - mode: 644

openhab.service:
  file.managed:
    - name: /etc/systemd/system/openhab.service
    - source: salt://files/docker-compose/systemd.service
    - template: jinja
    - user: root
    - group: root
    - context:
      compose_path: /opt/openhab/
  service.running:
    - enable: True
    - watch:
      - file: /opt/openhab/*
