# Tiny-RSS (tt-rss) service
# https://tt-rss.org/wiki/InstallationNotes/

{{ pillar.trss.data_dir}}:
  file.directory:
    - makedirs: True
    - user:  {{ salt['pillar.get']('static:uids:www-data') }}
    - group:  {{ salt['pillar.get']('static:uids:www-data') }}
    - mode:  755

{% import "roles/docker-compose-macro.sls" as compose %}
{{ compose.service('trss') }}
