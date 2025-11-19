{% import_yaml 'static.yaml' as static %}
users:
  github:
    home: /home/github
    uid: {{ static.uids.github }}
    groups:
      - docker
