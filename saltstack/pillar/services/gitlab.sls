{% import_yaml 'static.yaml' as static %}

roles:
  - docker
  - nginx
  - gitlab

jenkins:
  version: 2.235.5
  data_dir: /srv/gitlab-data
  dirs:
    - /srv/gitlab-data

proxy_vhosts:
  gitlab:
    domain: gitlab-dev.local.pws
    port: {{ static.proxy_ports.gitlab_http }}
    ssl: internal
    ssl_name: local
