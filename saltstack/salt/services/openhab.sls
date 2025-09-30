
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

{% for z2m_id, z2m in  pillar.openhab.zigbee2mqtt.instances.items() %}
{% set z2m_data_dir = pillar.openhab.zigbee2mqtt.data_dir + '/' + z2m_id %}
{% set z2m_container_base_id = pillar.openhab.zigbee2mqtt.id %}
{% set z2m_secrets = salt['pillar.get']('pws_secrets:openhab:zigbee2mqtt:instances:' + z2m_id) %}

{{ z2m_data_dir }}:
  file.directory:
    - makedirs: True
    - user:  {{ pillar.static.uids.master }}
    - group:  {{ pillar.static.uids.master }}
    - mode:  755

/etc/logrotate.d/zigbee2mqtt-{{ pillar.openhab.id }}-{{ z2m_id }}:
  file.managed:
    - makedirs: True
    - contents: |
        {{ z2m_data_dir }}/log/*.txt
        {
          missingok
          daily
          copytruncate
          rotate 7
          compress
          notifempty
        }

{{ z2m_data_dir }}/configuration.yaml:
  file.managed:
    - makedirs: True
    - contents: |
        homeassistant:
          enabled: false
        availability:
          enabled: true
          active:
            timeout: 10
          passive:
            timeout: 1500
        mqtt:
          base_topic: {{ z2m.topic | default('z2m-' + z2m_id) }}
          server: mqtt://mosquitto
          user: {{ z2m_secrets.mqtt_user }}
          password: {{ z2m_secrets.mqtt_password }}
        serial:
          adapter: zstack
          port: /dev/serial/by-id/{{ z2m.device }}
          rtscts: false
        frontend:
          enabled: true
          port: 3001
          host: 0.0.0.0
          package: zigbee2mqtt-windfront
        advanced:
          log_output:
            - file
          log_rotation: false
          log_symlink_current: false
          log_directory: data/log
          log_file: log.txt
          pan_id: {{ z2m.pan_id }}
          # (Note: use a ZLL channel: 11, 15, 20, or 25 to avoid problems)
          channel: {{ z2m.channel }}
          network_key: '!secrets.yaml network_key'
          log_level: info
        device_options: {}
        devices: devices.yaml
        version: 4

{{ z2m_data_dir }}/secrets.yaml:
  file.managed:
    - makedirs: True
    - contents: |
        network_key: {{ z2m_secrets.key | yaml }}
{% endfor %}

openhab-deps:
  pkg.installed:
    - pkgs:
      - mosquitto-clients
      - python3-lxml
      - python3-paho-mqtt
      - python3-dateparser

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
