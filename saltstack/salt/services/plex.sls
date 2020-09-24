{% for dir in ['/'] %}
plex-dir-{{ dir }}:
  file.directory:
    - name:  {{ pillar.plex.data_dir + dir }}
    - makedirs: True
    - user: {{ pillar.static.uids.master }}
    - group: {{ pillar.static.uids.master }}
{% endfor %}

{% import "roles/docker-compose-macro.sls" as compose %}
{{ compose.service('plex') }}
