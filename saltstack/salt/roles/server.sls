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

# Drop some packages
server-blacklisted:
  pkg.purged:
    - pkgs:
      - snapd

# Configure Journald
/etc/systemd/journald.conf:
  file.managed:
    - contents: |
        [Journal]
        Storage={{ pillar.journald.storage }}
