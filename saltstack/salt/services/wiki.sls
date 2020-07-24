# WikiMedia

wiki-rootdir:
  file.directory:
    - name:  /opt/wiki
    - makedirs: True
    - user:  root
    - group:  root
    - mode:  755

wiki-dir-images:
  file.directory:
    - name:  /opt/wiki/images
    - user:  root
    - group:  root
    - mode:  777

wiki-dir-extensions:
  file.directory:
    - name:  /opt/wiki/extensions
    - user:  root
    - group:  root
    - mode:  644

wiki-ext-tinyMCE:
  git.latest:
    - user: root
    - name: https://gerrit.wikimedia.org/r/mediawiki/extensions/TinyMCE.git
    - target: /opt/wiki/extensions/TinyMCE
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
    - source: salt://files/pws-web-vm/wiki/docker-compose.yml
    - template: jinja
    - user: root
    - group: root
    - mode: 644

wiki-upload-config:
  file.managed:
    - name: /opt/wiki/uploads.ini
    - source: salt://files/pws-web-vm/wiki/uploads.ini
    - template: jinja
    - user: root
    - group: root
    - mode: 644

compose-wiki.service:
  file.managed:
    - name: /etc/systemd/system/compose-wiki.service
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

