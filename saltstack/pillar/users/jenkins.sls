{% import_yaml 'static.yaml' as static %}
users:
  jenkins:
    home: /home/jenkins
    uid: {{ static.uids.jenkins }}
    groups:
      - docker
