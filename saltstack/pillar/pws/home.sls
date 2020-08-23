# Smart-home root server has it's own config

roles:
  - nginx
  - mounts

check_mk_plugins:
  - nginx_status

proxy_vhosts:
  home:
    domain: home-dev.local.pws
    port: 8080
    ssl: internal
    ssl_name: local

mounts:
  openhab-sys:
    name: /srv/openhab2-sys
    device: /usr/share/openhab2
    type: none
    opts: bind
  openhab-conf:
    name: /srv/openhab2-conf
    device: /etc/openhab2
    type: none
    opts: bind
  openhab-userdata:
    name: /srv/openhab2-userdata
    device: /var/lib/openhab2
    type: none
    opts: bind
  openhab-logs:
    name: /srv/openhab2-logs
    device: /var/log/openhab2
    type: none
    opts: bind
  openhab-addons:
    name: /srv/openhab2-addons
    device: /usr/share/openhab2/addons
    type: none
    opts: bind
