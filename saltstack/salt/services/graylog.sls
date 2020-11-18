{% for dir,uid in {'app':1100,'mongo':999,'elastic':1000}.items() %}
graylog-dir-{{ dir }}:
  file.directory:
    - name: {{ pillar.graylog.data_dir }}/{{ dir }}
    - makedirs: True
    - user: {{ uid }}
    - group: {{ uid }}
    - mode:  755
{% endfor %}

{% import "roles/docker-compose-macro.sls" as compose %}
{{ compose.service('graylog') }}
