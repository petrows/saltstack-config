system-salt-masterconf:
  file.managed:
    - name: /etc/salt/master
    - source: salt://files/pws-system/salt-master.yml
    - template: jinja
    - user: root
    - group: root
    - mode: 644
