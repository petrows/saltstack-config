check_mk_plugins:
  - nginx_status.py
  - mk_docker.py

roles:
  - docker

include:
  - services.nginx
