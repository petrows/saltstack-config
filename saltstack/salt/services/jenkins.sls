{% for dir in salt.pillar.get('jenkins:dirs', []) %}
jenkins-dir-{{ dir }}:
  file.directory:
    - name:  {{ dir }}
    - makedirs: True
    - user: 1000
    - group: 1000
    - mode:  755
{% endfor %}

{% import "roles/docker-compose-macro.sls" as compose %}
{{ compose.service('jenkins') }}
