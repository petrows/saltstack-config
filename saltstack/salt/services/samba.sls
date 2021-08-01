{% for dir in ['/lib', '/lib/private'] %}
samba-dir-{{ dir }}:
  file.directory:
    - name:  {{ pillar.samba.data_dir + dir }}
    - makedirs: True
{% endfor %}

{% for share_id, share in salt['pillar.get']('samba:shares', {}).items() %}
samba-dir-{{ share_id }}:
  file.directory:
    - name:  {{ share.path }}
    - makedirs: True
    - user: {{ pillar.samba.user }}
    - group: {{ pillar.samba.user }}
{% endfor %}

{% for user_name, user_id in salt['pillar.get']('samba:smb_users', {}).items() %}
samba-group-{{ user_name }}:
  group.present:
    - name: '{{ user_name }}'
    - gid: {{ user_id }}
samba-user-{{ user_name }}:
  user.present:
    - name: '{{ user_name }}'
    - uid: {{ user_id }}
    - gid: {{ user_id }}
    - createhome: False
    - home: '/tmp'
{% endfor %}

{% import "roles/docker-compose-macro.sls" as compose %}
{{ compose.service('samba') }}
