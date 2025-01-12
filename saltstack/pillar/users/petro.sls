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
      - admin
    sudo: True
    sudo_nopassword: True
    polkit: True

firefox:
  user: petro
