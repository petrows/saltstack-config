{% for id, item in salt['pillar.get']('photoprism:volumes', {}).items() %}
{{ item.path }}:
  file.directory:
    - makedirs: True
    - user: {{ salt['pillar.get']('static:uids:master') }}
    - group: {{ salt['pillar.get']('static:uids:master') }}
    - mode: 755
{% endfor %}

photoprism-dir-app:
  file.directory:
    - name: {{ pillar.photoprism.data_dir }}
    - makedirs: True
    - user: {{ salt['pillar.get']('static:uids:master') }}
    - group: {{ salt['pillar.get']('static:uids:master') }}
    - mode: 755

photoprism-dir-db:
  file.directory:
    - name: {{ pillar.photoprism.mariadb.data_dir }}
    - makedirs: True
    - user: 999
    - group: 999
    - mode: 755

# Updates watcher service

/usr/bin/photoprism-watch:
  file.managed:
    - source: salt://files/photoprism/photoprism-watch.py
    - mode: 755

photoprism-watch.service:
  file.managed:
    - name: /etc/systemd/system/photoprism-watch.service
    - contents: |
        [Unit]
        Description=Photoprism watch for updates
        After=network.target photoprism.service
        OnFailure=status-email@%n.service
        [Service]
        User=root
        Group=root
        Type=notify
        WorkingDirectory=/
        ExecStart=/opt/venv/app/bin/python /usr/bin/photoprism-watch --delay 60 --container "{{ pillar.photoprism.id }}" "{{ pillar.photoprism.volumes.originals.path }}"
        [Install]
        WantedBy=multi-user.target
  service.running:
    - enable: True
    - watch:
      - file: /etc/systemd/system/sync-fotos-watch.service

{% import "roles/docker-compose-macro.sls" as compose %}
{{ compose.service('photoprism') }}
