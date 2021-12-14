{% import_yaml 'static.yaml' as static %}

roles:
  - docker
  - nginx
  - jenkins

jenkins:
  version: 2.325
  data_dir: /srv/jenkins-data
  dirs:
    - /srv/jenkins-data
  agent_port: {{ static.proxy_ports.jenkins_agent }}

proxy_vhosts:
  jenkins:
    domain: jenkins-dev.local.pws
    port: {{ static.proxy_ports.jenkins_http }}
    ssl: internal
    ssl_name: local
