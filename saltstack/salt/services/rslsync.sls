rslsync-extract:
  archive.extracted:
    - name: /opt/rslsync
    - source: {{ pillar.rslsync.download_url }}
    - skip_verify: True
    - enforce_toplevel: False

rslsync-dir-config:
  file.directory:
    - name: {{ pillar.rslsync.data_dir }}
    - makedirs: True
    - user: {{ pillar.rslsync.user }}
    - group: {{ pillar.rslsync.user }}

rslsync.service:
  file.managed:
    - name: /etc/systemd/system/rslsync.service
    - source: salt://files/rslsync/rslsync.service
    - template: jinja
  service.running:
    - enable: True
    - watch:
      - archive: rslsync-extract
