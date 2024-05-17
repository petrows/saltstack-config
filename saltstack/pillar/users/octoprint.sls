{% import_yaml 'static.yaml' as static %}
users:
  octoprint:
    home: /home/octoprint
    uid: {{ static.uids.octoprint }}
    groups:
      - tty
      - dialout
      - video
    sudo: True
    sudo_nopassword: True
