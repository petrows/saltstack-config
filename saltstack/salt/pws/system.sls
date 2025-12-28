# Updates-checker script
services-upgrade-checker.service:
  file.managed:
    - name: /etc/systemd/system/services-upgrade-checker.service
    - source: salt://files/upgrade-checker/services-upgrade-checker.service
    - template: jinja
  service.enabled:
    - enable: True

services-upgrade-checker.timer:
  file.managed:
    - name: /etc/systemd/system/services-upgrade-checker.timer
    - source: salt://files/upgrade-checker/services-upgrade-checker.timer
    - template: jinja
  service.running:
    - enable: True

# Bambu printer watch service script
/opt/bambu-bot:
  file.recurse:
    - source: salt://files/bambu-bot/
    - user: root
    - group: root
    - dir_mode: 755
    - file_mode: 644

/opt/bambu-bot/dumps:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 755
    - file_mode: 644

/opt/bambu-bot/bambu.yaml:
  file.serialize:
    - dataset_pillar: 'pws_secrets:bambu'

/opt/bambu-bot/.venv:
  virtualenv.managed:
    - user: root
    - system_site_packages: False
    - requirements: salt://files/bambu-bot/requirements.txt

bambu-bot.service:
  file.managed:
    - name: /etc/systemd/system/bambu-bot.service
    - contents: |
        [Unit]
        Description=Bambu Bot Service
        After=network.target

        [Service]
        ExecStart=/opt/bambu-bot/.venv/bin/python3 /opt/bambu-bot/bambu-bot.py --cfg /opt/bambu-bot/bambu.yaml -l info
        User=root
        WorkingDirectory=/opt/bambu-bot/

        [Install]
        WantedBy=multi-user.target
  service.running:
    - enable: True
    - watch:
      - file: /opt/bambu-bot
      - file: /etc/systemd/system/bambu-bot.service
