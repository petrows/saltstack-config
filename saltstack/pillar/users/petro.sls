roles:
  - docker

users:
  petro:
    home: /home/petro
    uid: 1000
    groups:
      - docker
      - video
      - dialout
    sudo: True
    sudo_nopassword: True

firefox:
  user: petro
