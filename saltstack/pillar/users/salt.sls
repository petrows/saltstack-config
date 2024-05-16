{% import_yaml 'static.yaml' as static %}
users:
  salt:
    home: /home/salt
    shell: /bin/bash
    uid: {{ static.uids.salt }}
    install_profile: False
    sudo: True
    sudo_nopassword: True
