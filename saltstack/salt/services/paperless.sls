# WikiMedia

{% for dir in salt['pillar.get']('paperless:dirs', []) %}
{{ dir }}:
  file.directory:
    - makedirs: True
    - user:  {{ salt['pillar.get']('static:uids:master') }}
    - group:  {{ salt['pillar.get']('static:uids:master') }}
    - mode:  755
{% endfor %}

# Updates watcher service

/usr/bin/paperless-watch:
  file.managed:
    - source: salt://files/paperless/paperless-watch.py
    - mode: 755

paperless-watch.service:
  file.managed:
    - name: /etc/systemd/system/paperless-watch.service
    - contents: |
        [Unit]
        Description=Paperless watch for updates
        After=network.target paperless.service
        [Service]
        User=root
        Group=root
        Type=notify
        WorkingDirectory=/
        ExecStartPre=/bin/sleep 60
        ExecStart=/opt/venv/app/bin/python /usr/bin/paperless-watch -l INFO --url https://{{ pillar.proxy_vhosts.paperless.domain }} --token {{ pillar.pws_secrets.paperless.api_token }} {{ pillar.paperless.dirs_watch|join(' ')}}
        [Install]
        WantedBy=multi-user.target
  service.running:
    - enable: True
    - watch:
      - file: /etc/systemd/system/paperless-watch.service
      - file: /usr/bin/paperless-watch


{% import "roles/docker-compose-macro.sls" as compose %}
{{ compose.service('paperless') }}
