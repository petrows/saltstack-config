# Config for Julia RPI

{% import_yaml 'static.yaml' as static %}

check_mk_plugins:
  - mk_docker.py

roles:
  - wireguard-server

wireguard-server:
  'julua-pws':
    address: 10.80.7.6/32
