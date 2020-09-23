{% for dir in ['/lib', '/lib/private'] %}
samba-dir-{{ dir }}:
  file.directory:
    - name:  {{ pillar.samba.data_dir + dir }}
    - makedirs: True
{% endfor %}

{% import "roles/docker-compose-macro.sls" as compose %}
{{ compose.service('samba') }}
