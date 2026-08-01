# Script to dump tracker info

/usr/local/bin/pawfit2mqtt:
  file.managed:
    - source: salt://files/pawfit/pawfit2mqtt.py
    - mode: 0755

pawfit2mqtt.service:
  file.managed:
    - name: /etc/systemd/system/pawfit2mqtt.service
    - contents: |
        [Unit]
        Description=pawfit2mqtt
        After=network.target
        OnFailure=status-email@%n.service
        [Service]
        Type=notify
        WorkingDirectory=/
        ExecStart=/opt/venv/app/bin/python /usr/local/bin/pawfit2mqtt --pawfit-user "{{ pillar.pws_secrets.pawfit.user }}" --pawfit-pass "{{ pillar.pws_secrets.pawfit.pass }}" --mqtt-host {{ pillar.pws_secrets.openhab.mosquitto.home.host }} --mqtt-user {{ pillar.pws_secrets.openhab.mosquitto.home.user }} --mqtt-pass {{ pillar.pws_secrets.openhab.mosquitto.home.password }} -v --json-only --interval 60
        [Install]
        WantedBy=multi-user.target
  service.running:
    - enable: True
    - watch:
      - file: /etc/systemd/system/pawfit2mqtt.service
