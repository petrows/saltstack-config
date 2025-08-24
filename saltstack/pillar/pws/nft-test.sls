roles:
  - nftables
#  - docker

include:
  - services.nginx

iptables:
  managed: False

# Common firewall config
firewall:
  # Default policy for INPUT chain
  strict_mode: True
  # Ports, which are open for all
  ports_open:
    http:
      dst: 80
    https:
      dst: 443
    proxy:
      dst: 8080

