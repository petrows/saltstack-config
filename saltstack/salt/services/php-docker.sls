# This service reads records from vhosts with php-docker type

{% import "roles/docker-compose-macro.sls" as compose %}

php-docker-fpm-nginx-conf:
  file.managed:
    - name: /etc/nginx/php-docker.conf
    - source: salt://files/nginx/php-docker.conf
    - template: jinja
    - makedirs: True

{% for conf_id, conf in (salt['pillar.get']('proxy_vhosts', {})).items() %}
{% set conf_type = conf.type|default(None) %}
{% if conf_type == 'php-docker' %}

{% set php_options = conf.php.cfg|default({}) %}

{{ conf_id }}-php.ini:
  file.managed:
    - name: /opt/{{ conf_id }}/php.ini
    - makedirs: True
    - contents: |
        ; Managed by Salt
        {%- for opt_id, opt in php_options.items() %}
        {{ opt_id }} = {{ opt }}
        {%- endfor %}
    - watch_in:
      - service: {{ conf_id }}.service

{{ conf_id }}-dir-web:
  file.directory:
    - name: {{ conf.root }}/web
    - makedirs: True
    - user: {{ conf.php.user }}
    - group: {{ conf.php.user }}
    - mode: 700

{{ compose.service(conf_id, {'compose_file': 'salt://files/php-docker/compose'} ) }}

{% endif %}
{% endfor %}
