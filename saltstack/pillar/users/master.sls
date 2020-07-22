{% import_yaml 'uids.yaml' as user_ids %}
users:
  master:
    home: /home/master
    uid: {{ user_ids.master }}
