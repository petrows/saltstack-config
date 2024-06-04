# PrivateBin

{{ pillar.privatebin.data_dir }}/data:
  file.directory:
    - makedirs: True
    - user:  {{ salt['pillar.get']('static:uids:master') }}
    - group:  {{ salt['pillar.get']('static:uids:master') }}
    - mode:  755

{{ pillar.privatebin.data_dir }}/conf.php:
  file.managed:
    - makedirs: True
    - source: salt://files/privatebin/conf.php
    - watch_in:
      - service: privatebin.service

{% import "roles/docker-compose-macro.sls" as compose %}
{{ compose.service('privatebin') }}
