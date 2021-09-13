{% for dir in salt['pillar.get']('nextcloud:dirs', []) %}
nextcloud-dir-{{ dir }}:
  file.directory:
    - name: {{ pillar.nextcloud.data_dir }}/{{ dir }}
    - makedirs: True
    - user: {{ salt['pillar.get']('static:uids:www-data') }}
    - group: {{ salt['pillar.get']('static:uids:www-data') }}
    - mode: 755
{% endfor %}

nextcloud-dir-db:
  file.directory:
    - name: {{ pillar.nextcloud.data_dir }}/db
    - makedirs: True
    - user: 999
    - group: 999
    - mode: 755

{% import "roles/docker-compose-macro.sls" as compose %}
{{ compose.service('nextcloud') }}
