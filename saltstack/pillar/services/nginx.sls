roles:
  - nginx

check_mk_plugins:
  - nginx_status.py

firewall:
  ports_open:
    nginx-http:
      dst: 80
    nginx-https:
      dst: 443
    nginx-stream:
      dst: 4343
