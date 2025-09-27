# Salt to provide SFT backend for PhotoSync app for iPhone

{% for instance_id, instance in salt['pillar.get']('photosync-sftp:instances', {}).items() %}
{% set service_id = 'photosync-sftp-' + instance_id %}

# Working folders
# Contains secrets: make as root
/srv/{{ service_id }}:
  file.directory:
    - user: root
    - group: root
    - mode: 700
    - makedirs: True

# Host keys check/generation
{{ service_id }}-ssh_host_ed25519_key:
  cmd.run:
    - name: |
        ssh-keygen -t ed25519 -f /srv/{{ service_id }}/ssh_host_ed25519_key -N ''
    - creates: /srv/{{ service_id }}/ssh_host_ed25519_key

{% import "roles/docker-compose-macro.sls" as compose %}
{{ compose.service(service_id, {'compose_file': 'salt://files/photosync-sftp/compose', 'cfg': instance, 'instance': instance_id} ) }}

{% endfor %}
