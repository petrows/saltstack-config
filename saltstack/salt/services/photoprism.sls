{% for id, dir in salt['pillar.get']('photoprism:volumes', {}).items() %}
{{ dir }}:
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

{% import "roles/docker-compose-macro.sls" as compose %}
{{ compose.service('photoprism') }}
