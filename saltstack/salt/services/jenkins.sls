{% for dir in salt.pillar.get('jenkins:dirs', []) %}
jenkins-dir-{{ dir }}:
  file.directory:
    - name:  {{ dir }}
    - makedirs: True
    - user: 1000
    - group: 1000
    - mode:  755
{% endfor %}

jenkins-compose:
  file.managed:
    - name: /opt/jenkins/docker-compose.yml
    - source: salt://files/jenkins/docker-compose.yml
    - template: jinja
    - makedirs: True
    - user: root
    - group: root
    - mode: 644

jenkins.service:
  file.managed:
    - name: /etc/systemd/system/jenkins.service
    - source: salt://files/docker-compose/systemd.service
    - template: jinja
    - user: root
    - group: root
    - context:
      compose_path: /opt/jenkins/
  service.running:
    - enable: True
    - watch:
      - file: /opt/jenkins/*
