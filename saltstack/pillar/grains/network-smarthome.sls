# Config for machines in LAN

network:
  type: lan
  ntp: '10.80.6.1'
  dns: '10.80.6.1'

check_mk_agent:
  ssh: True
  base: salt://packages/

ssh:
  keys:
    cmk@pws:
      user: root
      enc: ssh-ed25519
      key: AAAAC3NzaC1lZDI1NTE5AAAAIM2VATkbpNf60uNLhDq7BfibGpeaYdTr22VKPXFXMhR9
      opts:
        - command="/usr/bin/check_mk_agent"
