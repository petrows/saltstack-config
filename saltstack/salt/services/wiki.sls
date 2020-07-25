# WikiMedia

wiki-rootdir:
  file.directory:
    - name:  /opt/wiki
    - makedirs: True
    - user:  root
    - group:  root
    - mode:  755

{% for dir in pillar.get('wiki:dirs', []) %}
wiki-dir-{{ dir }}:
  file.directory:
    - name:  {{ dir }}
    - makedirs: True
    - user:  {{ pillar.static.uids.www-data }}
    - group:  {{ pillar.static.uids.www-data }}
    - mode:  755
{% endfor %}

wiki-ext-tinyMCE:
  git.latest:
    - user: root
    - name: https://gerrit.wikimedia.org/r/mediawiki/extensions/TinyMCE.git
    - target: /opt/wiki-data/extensions/TinyMCE
    - force_fetch: True
    - force_reset: True

wiki-dir-mysql:
  file.directory:
    - name:  /opt/wiki/mysql
    - user:  999
    - group:  999
    - mode:  700

wiki-compose:
  file.managed:
    - name: /opt/wiki/docker-compose.yml
    - source: salt://files/wiki/docker-compose.yml
    - template: jinja
    - user: root
    - group: root
    - mode: 644

wiki-upload-config:
  file.managed:
    - name: /opt/wiki-data/uploads.ini
    - source: salt://files/wiki/uploads.ini
    - template: jinja
    - user: root
    - group: root
    - mode: 644

wiki.service:
  file.managed:
    - name: /etc/systemd/system/wiki.service
    - source: salt://files/docker-compose/systemd.service
    - template: jinja
    - user: root
    - group: root
    - context:
      compose_path: /opt/wiki/
  service.running:
    - enable: True
    - watch:
      - file: /opt/wiki/*
