salt-minion-config:
  file.managed:
    - name: /etc/salt/minion.d/99-pws.conf
    - source: salt://files/servers/salt/minion.yml

salt-minion-update.service:
  file.managed:
    - name: /etc/systemd/system/salt-minion-update.service
    - source: salt://files/servers/salt-minion-update.service
    - template: jinja
    - user: root
    - group: root
  service.enabled:
    - enable: True

salt-minion-update.timer:
  file.managed:
    - name: /etc/systemd/system/salt-minion-update.timer
    - source: salt://files/servers/salt-minion-update.timer
    - template: jinja
    - user: root
    - group: root
  service.running:
    - enable: True

