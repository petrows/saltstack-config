roles:
  - nginx

check_mk_plugins:
  - nginx_status.py

iptables:
  ports_open:
    nginx:
      dst: 80,443
