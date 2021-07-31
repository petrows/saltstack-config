roles:
  - docker

users:
  pgolovachev:
    home: /home/pgolovachev
    uid: 1000
    groups:
      - docker
    sudo: True
    sudo_nopassword: True
