# Common / Additional scripts for all hosts

packages_pip3:
  - exifread
  - docker
  - watchdog
  - telegram-send
  - systemd-python
  - dnspython
  - netifaces
  - objectpath
  - packaging
  - pyyaml

packages:
  # Requered by pip systemd
  - libsystemd-dev
