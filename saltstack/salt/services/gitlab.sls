
gitlab-dir-config:
  file.directory:
    - name: {{ pillar.gitlab.data_dir }}/config
    - makedirs: True
    - user: root
    - group: root
    - mode: 775

gitlab-dir-data:
  file.directory:
    - name: {{ pillar.gitlab.data_dir }}/data
    - makedirs: True
    - user: root
    - group: root
    - mode: 755

gitlab-dir-logs:
  file.directory:
    - name: {{ pillar.gitlab.data_dir }}/logs
    - makedirs: True
    - user: root
    - group: root
    - mode: 755

{% import "roles/docker-compose-macro.sls" as compose %}
{{ compose.service('gitlab') }}
