{% import_yaml 'static.yaml' as static %}
users:
  master:
    home: /home/master
    uid: {{ static.uids.master }}
