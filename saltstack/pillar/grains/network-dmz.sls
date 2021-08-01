# Config for machines in DMZ

# Config for servers avaliable from world

# Watch for updates
check_mk_plugins:
  - mk_apt

# Auto updates for linux systems
roles:
  - unattended-upgrades

network:
  ntp: '0.de.pool.ntp.org 1.de.pool.ntp.org 2.de.pool.ntp.org 3.de.pool.ntp.org'
  dns: '8.8.8.8 8.8.4.4'

check_mk_agent:
  base: salt://packages/
