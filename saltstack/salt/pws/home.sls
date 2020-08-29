# Smart-home root server has it's own config

openhab-repository:
  pkgrepo.managed:
    - name: deb https://dl.bintray.com/openhab/apt-repo2 stable main
    - file: /etc/apt/sources.list.d/openhab.list
    - keyid: EDB7D0304E2FCAF629DF1163075721F6A224060A
    - keyserver: https://bintray.com/user/downloadSubjectPublicKey?username=openhab

openhab-package:
  pkg.installed:
    - install_recommends: True
    - pkgs:
      - openhab2
      - mosquitto
      - openjdk-11-jre-headless
      - python3-pip

openhab-package-pip:
  pip.installed:
    - bin_env: /usr/bin/pip3
    - pkgs:
      - paho-mqtt

openhab2.service:
  service.running:
    - enable: True

grafana-repository:
  pkgrepo.managed:
    - name: deb https://packages.grafana.com/oss/deb stable main
    - file: /etc/apt/sources.list.d/grafana.list
    - keyid: 4E40DDF6D76E284A4A6780E48C8C34C524098CB6
    - keyserver: https://packages.grafana.com/gpg.key

grafana-package:
  pkg.installed:
    - install_recommends: True
    - pkgs:
      - grafana
    - require:
      - pkgrepo: grafana-repository

grafana-server.service:
  service.running:
    - enable: True

# Static content folder
openhab-static-content:
  file.directory:
    - name: /srv/static
    - user: openhab
    - group: openhab
    - mode: 755

# Zigbee2mqtt

z2mqtt-node-repository:
  pkgrepo.managed:
    - name: deb https://deb.nodesource.com/node_12.x {{ grains.oscodename|lower }} main
    - file: /etc/apt/sources.list.d/nodesource.list
    - keyid: 9FD3B784BC1C6FC31A8A0A1C1655A0AB68576280
    - keyserver: hkp://p80.pool.sks-keyservers.net:80

z2mqtt-node-pkg:
  pkg.installed:
    - pkgs:
      - nodejs
      - git
      - make
      - g++
      - gcc
    - install_recommends: True
    - refresh: True
    - require:
      - pkgrepo: z2mqtt-node-repository

z2mqtt-dir-data:
  file.directory:
    - name: /srv/zigbee2mqtt-data
    - user: openhab
    - group: openhab
    - mode: 755

z2mqtt-dir-app:
  file.directory:
    - name: /opt/zigbee2mqtt
    - user: openhab
    - group: openhab
    - mode: 755

z2mqtt-app:
  git.latest:
    - user: openhab
    - name: https://github.com/Koenkk/zigbee2mqtt.git
    - branch: master
    - target: /opt/zigbee2mqtt
    - force_fetch: True
    - force_reset: True
    - require:
      - pkg: z2mqtt-node-pkg

z2mqtt-app-install:
  cmd.run:
    - name: npm ci
    - cwd: /opt/zigbee2mqtt
    - runas: openhab
    - onchanges:
      - git: z2mqtt-app

zigbee2mqtt.service:
  file.managed:
    - name: /etc/systemd/system/zigbee2mqtt.service
    - source: salt://files/home/zigbee2mqtt.service
    - template: jinja
    - user: root
    - group: root
    - context:
      compose_path: /opt/zigbee2mqtt/
  service.running:
    - enable: True
    - watch:
      - git: z2mqtt-app

# Openhab cron jobs
openhab-hourly.service:
  file.managed:
    - name: /etc/systemd/system/openhab-hourly.service
    - source: salt://files/home/openhab-hourly.service
  service.enabled:
    - enable: True

openhab-hourly.timer:
  file.managed:
    - name: /etc/systemd/system/openhab-hourly.timer
    - source: salt://files/home/openhab-hourly.timer
  service.running:
    - enable: True
    - watch:
      - file: /etc/systemd/system/openhab-hourly.*
