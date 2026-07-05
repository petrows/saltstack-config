# WikiMedia

{% for dir in salt['pillar.get']('wiki:dirs', []) %}
wiki-dir-{{ dir }}:
  file.directory:
    - name:  {{ dir }}
    - makedirs: True
    - user:  {{ salt['pillar.get']('static:uids:www-data') }}
    - group:  {{ salt['pillar.get']('static:uids:www-data') }}
    - mode:  755
{% endfor %}

wiki-ext-tinyMCE:
  git.latest:
    - user: root
    - name: https://gerrit.wikimedia.org/r/mediawiki/extensions/TinyMCE
    - target: {{ pillar.wiki.data_dir }}/extensions/TinyMCE
    - force_fetch: True
    - force_reset: True

wiki-dir-mysql:
  file.directory:
    - name:  {{ pillar.wiki.data_dir }}/mysql
    - user:  999
    - group:  999
    - mode:  700

{{ pillar.wiki.data_dir }}/uploads.ini:
  file.managed:
    - source: salt://files/wiki/uploads.ini
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - watch_in:
      - service: wiki.service

{{ pillar.wiki.data_dir }}/LocalSettings.php:
  file.managed:
    - source: salt://files/wiki/LocalSettings.php
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - watch_in:
      - service: wiki.service

{% import "roles/docker-compose-macro.sls" as compose %}
{{ compose.service('wiki') }}
