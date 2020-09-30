system-salt-masterconf:
  file.managed:
    - name: /etc/salt/master
    - source: salt://files/pws-system/salt-master.yml
    - template: jinja
    - user: root
    - group: root
    - mode: 644

{% set pip3_location = salt['cmd.shell']('which pip3') %}

services-upgrade-checker-deps:
  pip.installed:
    - pkgs:
      - docker
      - objectpath
      - packaging
    - bin_env: {{ pip3_location }}

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
