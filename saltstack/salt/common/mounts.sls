# Server mounts
{% for mount_id, mount in salt['pillar.get']('mounts', {}).items() %}
{{ mount.name }}:
  mount.mounted:
    - name: {{ mount.name }}
    - device: {{ mount.device }}
    - fstype: {{ mount.type }}
    - mkmnt: True
    - opts: {{ mount.opts }}
{% endfor %}
