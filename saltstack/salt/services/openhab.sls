
{% for dir in salt.pillar.get('openhab:dirs', []) + salt.pillar.get('openhab:zigbee2mqtt:dirs', []) + salt.pillar.get('openhab:influxdb:dirs', []) %}
openhab-dir-{{ dir }}:
  file.directory:
    - name:  {{ dir }}
    - makedirs: True
    - user:  {{ pillar.static.uids.master }}
    - group:  {{ pillar.static.uids.master }}
    - mode:  755
{% endfor %}

{% for dir in salt.pillar.get('openhab:mosquitto:dirs', []) %}
openhab-dir-mosquitto-{{ dir }}:
  file.directory:
    - name:  {{ dir }}
    - makedirs: True
    - user:  1883
    - group:  1883
    - mode:  755
{% endfor %}

{% for dir in salt.pillar.get('openhab:grafana:dirs', []) %}
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

openhab-deps:
  pkg.installed:
    - pkgs:
      - mosquitto-clients
      - python3-lxml
      - python3-paho-mqtt

openhab-compose:
  file.managed:
    - name: /opt/openhab/docker-compose.yml
    - source: salt://files/openhab/docker-compose.yml
    - template: jinja
    - makedirs: True
    - user: root
    - group: root
    - mode: 644

openhab.service:
  file.managed:
    - name: /etc/systemd/system/openhab.service
    - source: salt://files/docker-compose/systemd.service
    - template: jinja
    - user: root
    - group: root
    - context:
      compose_path: /opt/openhab/
  service.running:
    - enable: True
    - watch:
      - file: /opt/openhab/*

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
