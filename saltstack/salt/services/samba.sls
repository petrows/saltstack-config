{% for dir in ['/lib', '/lib/private'] %}
samba-dir-{{ dir }}:
  file.directory:
    - name:  {{ pillar.samba.data_dir + dir }}
    - makedirs: True
{% endfor %}

{% for share_id, share in salt.pillar.get('samba:shares', {}).items() %}
samba-dir-{{ share_id }}:
  file.directory:
    - name:  {{ share.path }}
    - makedirs: True
    - user: {{ pillar.samba.user }}
    - group: {{ pillar.samba.user }}
{% endfor %}

{% import "roles/docker-compose-macro.sls" as compose %}
{{ compose.service('samba') }}
