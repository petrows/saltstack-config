{% for dir in ['/'] %}
plex-dir-{{ dir }}:
  file.directory:
    - name:  {{ pillar.plex.data_dir + dir }}
    - makedirs: True
    - user: {{ pillar.static.uids.master }}
    - group: {{ pillar.static.uids.master }}
{% endfor %}

plex-compose:
  file.managed:
    - name: /opt/plex/docker-compose.yml
    - source: salt://files/plex/docker-compose.yml
    - template: jinja
    - makedirs: True

plex.service:
  file.managed:
    - name: /etc/systemd/system/plex.service
    - source: salt://files/docker-compose/systemd.service
    - template: jinja
    - context:
      compose_path: /opt/plex/
  service.running:
    - enable: True
    - watch:
      - file: /opt/plex/*
