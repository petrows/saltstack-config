rslsync-extract:
  archive.extracted:
    - name: /opt/rslsync
    - source: {{ pillar.rslsync.download_url }}
    - skip_verify: True
    - enforce_toplevel: False

# Instances config
{%- for conf_id, conf in (salt.pillar.get('rslsync:instances', {})).items() %}

rslsync-{{conf_id}}-dir-config:
  file.directory:
    - name: {{ conf.data_dir }}
    - makedirs: True
    - user: {{ conf.user }}
    - group: {{ conf.user }}

rslsync-{{conf_id}}.service:
  file.managed:
    - name: /etc/systemd/system/rslsync-{{conf_id}}.service
    - contents: |
        [Unit]
        Description=Resillio sync {{conf_id}}
        After=network.target
        [Service]
        User={{ conf.user }}
        Group={{ conf.user }}
        WorkingDirectory=/opt/rslsync
        ExecStart=/opt/rslsync/rslsync --nodaemon --webui.listen 0.0.0.0:{{ conf.port|default('8888') }} --storage {{ conf.data_dir }}
        [Install]
        WantedBy=multi-user.target
  service.running:
    - enable: True
    - watch:
      - archive: rslsync-extract
{% endfor %}
