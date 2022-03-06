{% import_yaml 'static.yaml' as static %}
users:
  www-data:
    home: /home/www-data
    uid: {{ static.uids['www-data'] }}
