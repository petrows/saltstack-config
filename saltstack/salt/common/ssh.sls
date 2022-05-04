
/etc/ssh/sshd_config:
  file.managed:
    - source: salt://files/sshd_config
    - template: jinja

sshd.service:
  service.running:
    - enable: True
    - watch:
      - file: /etc/ssh/*
