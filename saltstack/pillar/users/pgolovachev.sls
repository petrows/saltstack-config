roles:
  - docker

users:
  pgolovachev:
    home: /home/pgolovachev
    uid: 1000
    groups:
      - docker
      - video
    sudo: True
    sudo_nopassword: True

firefox:
  user: pgolovachev
