{% import_yaml 'static.yaml' as static %}

roles:
  - awg-server

# AWG requires to setup deb-src!
apt:
  use_src: True
