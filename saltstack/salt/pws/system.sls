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
