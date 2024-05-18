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

{% set db = conf.php.db | default({}) %}
{% set crontabs = conf.php.cron|default({}) %}
{% set php_options = conf.php.cfg|default({}) %}
{% set service_user = conf.php.user | default(salt['pillar.get']('php-docker:defaults:user')) %}

# Iterate via defaults array and update values
{% for def_id, def in (salt['pillar.get']('php-docker:defaults:cfg', {})).items() %}
# Use set value, otherwise from defaults
{% set cfg_val = php_options[def_id] | default(def) %}
# Set final value
{% do php_options.update( {def_id: cfg_val} ) %}
{% endfor %}

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
    - user: {{ service_user }}
    - group: {{ service_user }}
    - mode: 700

{% if db %}
{{ conf_id }}-dir-db:
  file.directory:
    - name: /srv/{{ conf_id }}/db
    - makedirs: True
    - mode: 700
    - user: {{ service_user }}
    - group: {{ service_user }}
{% endif %}

# Crontabs defined?
{% for cron_id, cron in crontabs.items() %}
{% set systemd_id = conf_id + '-' + cron_id %}
{{ systemd_id }}.service:
  file.managed:
    - name: /etc/systemd/system/{{ systemd_id }}.service
    - contents: |
        [Unit]
        Description=Systemd cron: {{ systemd_id }}
        OnFailure=status-email@%n.service
        [Service]
        Type=simple
        RemainAfterExit=no
        ExecStart=docker exec {{ conf_id }}-fpm bash -c '{{ cron.cmd }}'
  service.enabled:
    - enabled: True
{{ systemd_id }}.timer:
  file.managed:
    - name: /etc/systemd/system/{{ systemd_id }}.timer
    - contents: |
        [Unit]
        Description=Systemd cron timer: {{ systemd_id }}
        [Timer]
        OnCalendar={{ cron.calendar }}
        RandomizedDelaySec=60
        [Install]
        WantedBy=timers.target
  service.running:
    - enable: True
    - full_restart: True
    - watch:
      - file:  /etc/systemd/system/{{ systemd_id }}.timer
{% endfor %} # Crontabs

{{ compose.service(conf_id, {'compose_file': 'salt://files/php-docker/compose'} ) }}

{% endif %}
{% endfor %}
