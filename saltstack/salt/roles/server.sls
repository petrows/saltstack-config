salt-minion-config:
  file.managed:
    - name: /etc/salt/minion.d/99-pws.conf
    - source: salt://files/servers/salt/minion.yml
    - template: jinja

salt-minion-update.service:
  file.managed:
    - name: /etc/systemd/system/salt-minion-update.service
    - source: salt://files/servers/salt-minion-update.service
    - template: jinja
  service.enabled:
    - enable: True

salt-minion-update.timer:
  file.managed:
    - name: /etc/systemd/system/salt-minion-update.timer
    - source: salt://files/servers/salt-minion-update.timer
    - template: jinja
  service.running:
    - enable: True

# Configure notication bot
telegram-send-config:
  file.managed:
    - name: /etc/telegram-send.conf
    - contents: |
        [telegram]
        token = {{ pillar.pws_secrets.telegram_notification_bot.token }}
        chat_id = {{ pillar.pws_secrets.telegram_notification_bot.chat_id }}
    - require:
      - pip: telegram-send
