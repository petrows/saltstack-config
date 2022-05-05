roles:
  - nginx

check_mk_plugins:
  - nginx_status.py

iptables:
  ports_open:
    nginx-http:
      dst: 80
    nginx-https:
      dst: 443
