check_mk_plugins:
  - mk_docker.py

roles:
  - docker

packages:
  - ghostscript
  - hplip

rslsync:
  instances:
    petro:
      data_dir: /srv/rslsync-data-petro
      user: master
      port: 8888
    marina:
      data_dir: /srv/rslsync-data-marina
      user: master
      port: 8889
