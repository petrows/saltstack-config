{% for dir in ['/lib', '/lib/private'] %}
samba-dir-{{ dir }}:
  file.directory:
    - name:  {{ pillar.samba.data_dir + dir }}
    - makedirs: True
{% endfor %}

samba-config:
  file.managed:
    - name: /opt/samba/smb.conf
    - source: salt://files/samba/smb.conf.j2
    - template: jinja
    - makedirs: True

samba-compose:
  file.managed:
    - name: /opt/samba/docker-compose.yml
    - source: salt://files/samba/docker-compose.yml
    - template: jinja
    - makedirs: True

samba-dockerfile:
  file.managed:
    - name: /opt/samba/Dockerfile
    - source: salt://files/samba/Dockerfile
    - template: jinja
    - makedirs: True

samba.service:
  file.managed:
    - name: /etc/systemd/system/samba.service
    - source: salt://files/docker-compose/systemd.service
    - template: jinja
    - context:
      compose_path: /opt/samba/
  service.running:
    - enable: True
    - watch:
      - file: /opt/samba/*
