# Config for Bare-metal

roles:
  - server-dedicated

packages:
  - sudo
  - lm-sensors

include:
  - common.coretemp
