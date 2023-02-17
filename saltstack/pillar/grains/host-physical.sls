# Config for Bare-metal

roles:
  - server-dedicated

packages:
  - sudo
  - lm-sensors
  - smartmontools

include:
  - common.coretemp
