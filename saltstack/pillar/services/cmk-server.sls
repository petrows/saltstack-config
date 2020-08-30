# We are using bare metal run due to:
# 1. Recommendation: https://checkmk.com/cms_introduction_docker.html
# 2. It already shipped with built-in version control system

{% import_yaml 'static.yaml' as static %}

roles:
  - docker
  - nginx
  - cmk-server

check_mk_server:
  url: https://checkmk.com/support/1.6.0p16/check-mk-raw-1.6.0p16_0.focal_amd64.deb
  pkg: check-mk-raw-1.6.0p16

proxy_vhosts:
  cmk:
    domain: cmk-dev.local.pws
    port: {{ static.proxy_ports.cmk_http }}
    ssl: internal
    ssl_name: local
