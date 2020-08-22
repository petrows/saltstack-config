{% import_yaml 'static.yaml' as static %}

roles:
  - docker
  - nginx
  - gitlab

gitlab:
  version: 12.1.3-ce.0
  data_dir: /srv/gitlab-data

proxy_vhosts:
  gitlab:
    domain: gitlab-dev.local.pws
    port: {{ static.proxy_ports.gitlab_http }}
    ssl: internal
    ssl_name: local
