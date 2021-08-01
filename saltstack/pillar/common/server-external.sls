# Outside PWS network
# It can't download internal files

check_mk:
  url: False

network:
  ntp: '0.de.pool.ntp.org 1.de.pool.ntp.org 2.de.pool.ntp.org 3.de.pool.ntp.org'
  dns: '8.8.8.8 8.8.4.4'
