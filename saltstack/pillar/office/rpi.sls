# Config for office RPI

{% import_yaml 'static.yaml' as static %}

tmp_ramdisk: False

swap_size_mb: {{ 4 * 1024 }}

check_mk_plugins:
  - mk_docker.py

packages:
  - ghostscript
  - hplip
  - cups
  #- samba

users:
  pi:
    home: /home/pi
    uid: 1000
    groups:
      - lpadmin
    sudo: True
    sudo_nopassword: True
