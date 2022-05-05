{% import_yaml 'static.yaml' as static %}

roles:
#  - docker
#   - nginx
#  - gitlab

# Gitlab was hacked at 26 Nov by Cerber Ransomware and removed (as not used anymore)
{# gitlab:
  # IMPORTANT: https://docs.gitlab.com/ee/policy/maintenance.html#upgrade-recommendations
  # Check background-imgrations: gitlab-rails runner -e production 'puts Gitlab::BackgroundMigration.remaining'
  version: 13.3.0-ce.1
  data_dir: /srv/gitlab-data #}

proxy_vhosts:
  gitlab:
    domain: gitlab-dev.local.pws
    ssl: internal
    ssl_name: local
    type: redirect
    redirect_target: 'https://github.com/petrows'
