
{% for dir in salt['pillar.get']('openhab:dirs', []) + salt['pillar.get']('openhab:zigbee2mqtt:dirs', []) + salt['pillar.get']('openhab:influxdb:dirs', []) %}
openhab-dir-{{ dir }}:
  file.directory:
    - name:  {{ dir }}
    - makedirs: True
    - user:  {{ pillar.static.uids.master }}
    - group:  {{ pillar.static.uids.master }}
    - mode:  755
{% endfor %}

{% for dir in salt['pillar.get']('openhab:mosquitto:dirs', []) %}
openhab-dir-mosquitto-{{ dir }}:
  file.directory:
    - name:  {{ dir }}
    - makedirs: True
    - user:  1883
    - group:  1883
    - mode:  755
{% endfor %}

{% for dir in salt['pillar.get']('openhab:grafana:dirs', []) %}
openhab-dir-mosquitto-{{ dir }}:
  file.directory:
    - name:  {{ dir }}
    - makedirs: True
    - user:  472
    - group:  472
    - mode:  755
{% endfor %}

zigbee2mqtt-dir-data:
  file.directory:
    - name:  {{ pillar.openhab.zigbee2mqtt.data_dir }}
    - makedirs: True
    - user:  {{ pillar.static.uids.master }}
    - group:  {{ pillar.static.uids.master }}
    - mode:  755

# Optional configs
{% if pillar.openhab.yandex2mqtt.id %}
{{ pillar.openhab.yandex2mqtt.data_dir }}/loki.json:
  file.managed:
    - mode:  755
{{ pillar.openhab.yandex2mqtt.data_dir }}/loki.json~:
  file.managed:
    - mode:  755
{% endif %}

openhab-deps:
  pkg.installed:
    - pkgs:
      - mosquitto-clients
      - python3-lxml
      - python3-paho-mqtt
      - python3-dateparser

openhab-deps-pip:
  pip.installed:
    - pkgs:
      - diskcache
    - bin_env: {{ pillar.pip3_bin }}

# Config files
{{ pillar.openhab.mosquitto.data_dir }}/config/mosquitto.conf:
  file.managed:
    - contents: |
        listener 1883
        persistence true
        persistence_location /mosquitto/data/
        log_dest file /mosquitto/log/mosquitto.log
        include_dir /mosquitto/config/conf.d
        password_file /mosquitto/config/passwd
        allow_anonymous false
    - watch_in:
      - service: openhab.service

{% import "roles/docker-compose-macro.sls" as compose %}
{{ compose.service('openhab') }}

# Openhab cron jobs
openhab-hourly.service:
  file.managed:
    - name: /etc/systemd/system/openhab-hourly.service
    - source: salt://files/openhab/openhab-hourly.service
  service.disabled: []

openhab-hourly.timer:
  file.managed:
    - name: /etc/systemd/system/openhab-hourly.timer
    - source: salt://files/openhab/openhab-hourly.timer
  service.running:
    - enable: True
    - watch:
      - file: /etc/systemd/system/openhab-hourly.*

openhab-minute.service:
  file.managed:
    - name: /etc/systemd/system/openhab-minute.service
    - source: salt://files/openhab/openhab-minute.service
  service.disabled: []

openhab-minute.timer:
  file.managed:
    - name: /etc/systemd/system/openhab-minute.timer
    - source: salt://files/openhab/openhab-minute.timer
  service.running:
    - enable: True
    - watch:
      - file: /etc/systemd/system/openhab-minute.*
