{% import_yaml 'static.yaml' as static %}

roles:
  - docker
  - jenkins

include:
  - services.nginx

jenkins:
  # https://hub.docker.com/r/jenkins/jenkins/tags
  version: 2.440.3
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
