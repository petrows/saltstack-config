# Tiny-RSS (tt-rss) service
# https://tt-rss.org/wiki/InstallationNotes/
{% set provision_filters = salt['pillar.get']('trss:provision_filters', []) %}

{{ pillar.trss.data_dir}}:
  file.directory:
    - makedirs: True
    - user:  {{ salt['pillar.get']('static:uids:www-data') }}
    - group:  {{ salt['pillar.get']('static:uids:www-data') }}
    - mode:  755

# Provision filters?
{% for pf in provision_filters %}
{{ pillar.trss.data_dir}}/config.d/{{ pf }}:
  file.managed:
    - makedirs: True
    - source: salt://files/tiny-rss/{{ pf }}
{% endfor %}

{% import "roles/docker-compose-macro.sls" as compose %}
{{ compose.service('trss') }}

# Auto exec filters
{% if provision_filters %}
{% for pf in provision_filters %}
trss-exec-{{ pf }}:
  cmd.run:
    - name: docker compose exec -u app app php /opt/tt-rss/provision_filters.php /opt/tt-rss/config.d/{{ pf }}
    - cwd: /opt/trss
    - onchanges:
      - file: {{ pillar.trss.data_dir}}/config.d/{{ pf }}
      - file: {{ pillar.trss.data_dir}}
{% endfor %}

trss-relabel-all:
  cmd.run:
    - name: docker compose exec -u app app php /opt/tt-rss/relabel_existing.php
    - cwd: /opt/trss
    - onchanges:
      - file: {{ pillar.trss.data_dir}}/config.d/*
      - file: {{ pillar.trss.data_dir}}
{% endif %}
