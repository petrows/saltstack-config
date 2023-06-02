
{{ pillar.firefly.data_dir }}/data:
  file.directory:
    - makedirs: True
    - user: 33
    - group: 33
    - mode: 775

{{ pillar.firefly.data_dir }}/db:
  file.directory:
    - user:  999
    - group:  999
    - mode:  700

{% import "roles/docker-compose-macro.sls" as compose %}
{{ compose.service('firefly') }}
