# Server mounts
{% for mount_id, mount in salt.pillar.get('mount-folders', {}).items() %}
mount-folder-{{ mount_id }}-target:
  file.directory:
    - name:  {{ mount.device }}
    - user:  {{ mount.user|default('root') }}
    - group:  {{ mount.group|default('root') }}
    - mode:  {{ mount.mode|default(755) }}
mount-folder-{{ mount_id }}:
  mount.mounted:
    - name: {{ mount.name }}
    - device: {{ mount.device }}
    - fstype: none
    - opts: bind
    - mkmnt: True
{% endfor %}
