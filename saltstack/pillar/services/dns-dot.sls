# Configgure DNS-Over-TLS (DoT)
# using dnscrypt-proxy

roles:
  - dns-dot

dns_dot:
  # https://github.com/DNSCrypt/dnscrypt-proxy/releases
  version: 2.1.7
  # DNS-over-TLS server
  listen:
    - 127.0.0.1:153
  bootstrap:
    - 9.9.9.11:53
    - 1.1.1.1:53
    - 77.88.8.1:53
