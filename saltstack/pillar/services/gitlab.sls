{% import_yaml 'static.yaml' as static %}

roles:
  - docker
  - nginx
  - gitlab

gitlab:
  # IMPORTANT: https://docs.gitlab.com/ee/policy/maintenance.html#upgrade-recommendations
  # Check background-imgrations: gitlab-rails runner -e production 'puts Gitlab::BackgroundMigration.remaining'
  version: 13.3.0-ce.1
  data_dir: /srv/gitlab-data

proxy_vhosts:
  gitlab:
    domain: gitlab-dev.local.pws
    port: {{ static.proxy_ports.gitlab_http }}
    ssl: internal
    ssl_name: local
