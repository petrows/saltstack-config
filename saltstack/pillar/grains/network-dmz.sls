# Config for machines in DMZ

# Config for servers avaliable from world
# and protected by external DMZ firewall

# Watch for updates
check_mk_plugins:
  - mk_apt

# Auto updates for linux systems
roles:
  - unattended-upgrades

upgrades:
  auto: True

network:
  type: dmz
  ntp: '0.de.pool.ntp.org 1.de.pool.ntp.org 2.de.pool.ntp.org 3.de.pool.ntp.org'
  dns: '8.8.8.8 8.8.4.4'

iptables:
  # All machines in DMZ / EXT network must be more secured via firewall
  strict_mode: True

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
