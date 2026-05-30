{% if pillar.upgrades.auto %}

unattended-upgrades-pkg:
  pkg.installed:
    - pkgs:
      - unattended-upgrades

unattended-upgrades-periodic:
  file.managed:
    - name: /etc/apt/apt.conf.d/20periodic
    - source: salt://files/apt.d/20periodic
    - template: jinja

unattended-upgrades-unattended-upgrades:
  file.managed:
    - name: /etc/apt/apt.conf.d/50unattended-upgrades
    - source: salt://files/apt.d/50unattended-upgrades
    - template: jinja

{% else %}
unattended-upgrades-pkg:
  pkg.purged:
    - pkgs:
      - unattended-upgrades

unattended-upgrades-periodic:
  file.absent:
    - name: /etc/apt/apt.conf.d/20periodic

unattended-upgrades-unattended-upgrades:
  file.absent:
    - name: /etc/apt/apt.conf.d/50unattended-upgrades
{% endif %}
