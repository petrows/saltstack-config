roles:
  - docker

users:
  pgolovachev:
    home: /home/pgolovachev
    uid: 1000
    groups:
      - docker
      - video
      - dialout
      - admin
    sudo: True
    sudo_nopassword: True
    polkit: True

firefox:
  user: pgolovachev
