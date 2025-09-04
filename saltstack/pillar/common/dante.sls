# Socks5 proxy server

roles:
  - dante

dante:
  port: 1080
  if_external: eth0

firewall:
  ports_open:
    dante:
      dst: 1080
