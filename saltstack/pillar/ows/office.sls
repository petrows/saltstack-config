{% import_yaml 'static.yaml' as static %}

packages:
  - ghostscript
  - hplip
  - cups

users:
  master:
    groups:
      - lpadmin
    sudo: True
    sudo_nopassword: True
