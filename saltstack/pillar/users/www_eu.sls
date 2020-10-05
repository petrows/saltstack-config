{% import_yaml 'static.yaml' as static %}
users:
  www:
    home: /home/www
    uid: {{ static.uids.www_eu }}
