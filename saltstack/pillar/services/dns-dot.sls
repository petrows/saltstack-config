# Configgure DNS-Over-TLS (DoT)

roles:
  - dns-dot

dns_dot:
  # DNS-over-TLS server
  listen:
    - 127.0.0.153@53
    - 0::153@53
  # DNS-over-TLS upstream
  upstream:
    - ip: 1.1.1.1
      tls_auth_name: "cloudflare-dns.com"
    - ip: 1.0.0.1
      tls_auth_name: "cloudflare-dns.com"
