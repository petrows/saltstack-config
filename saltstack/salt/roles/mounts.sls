# Server mounts
{% for mount_id, mount in pillar.get('mounts', {}).items() %}
mounts-{{ mount_id }}:
  mount.mounted:
    - name: {{ mount.name }}
    - device: {{ mount.device }}
    - fstype: {{ mount.type }}
    - mkmnt: True
    - opts: {{ mount.opts }}
{% endfor %}
