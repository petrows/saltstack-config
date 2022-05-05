# Config for hosts:
#
# * Avaliable from world
# * Not behind LAN firewall (and DMZ)

iptables:
  # All machines in DMZ / EXT network must be more secured via firewall
  strict_mode: True
  # Do not answer on ping
  allow_ping: False

# Move SSH to custom port

ssh:
  port: 8144
  allow_pw: False
