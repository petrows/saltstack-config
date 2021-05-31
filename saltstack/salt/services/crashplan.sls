crashplan-dir-config:
  file.directory:
    - name: {{ pillar.crashplan.data_dir }}
    - makedirs: True
    - user: 1000
    - group: 1000
    - mode: 775

{% import "roles/docker-compose-macro.sls" as compose %}
{{ compose.service('crashplan') }}
