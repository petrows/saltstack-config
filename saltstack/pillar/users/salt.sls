{% import_yaml 'static.yaml' as static %}
users:
  salt:
    home: /home/salt
    uid: {{ static.uids.salt }}
    shell: /bin/bash
    install_profile: False
    sudo: True
    sudo_nopassword: True
