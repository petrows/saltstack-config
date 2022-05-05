{% import_yaml 'static.yaml' as static %}

roles:
  - docker
  - crashplan

include:
  - services.nginx

crashplan:
  # https://hub.docker.com/r/jlesage/crashplan-pro/
  version: v2.16.5
  mounts: []
  data_dir: /srv/crashplan-data

proxy_vhosts:
  crashplan:
    domain: crashplan-dev.local.pws
    port: {{ static.proxy_ports.crashplan_http }}
    ssl: internal
    ssl_name: local
    custom_config: |
        location /websockify {
          proxy_pass http://127.0.0.1:{{ static.proxy_ports.crashplan_http }};
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection $connection_upgrade;
          proxy_read_timeout 86400;
        }
