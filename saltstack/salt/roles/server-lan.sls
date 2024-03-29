
# Check that salt-minion installed
{% if salt['file.file_exists']('/lib/systemd/system/salt-minion.service') %}

salt-minion-config:
  file.managed:
    - name: /etc/salt/minion.d/99-pws.conf
    - source: salt://files/servers/salt/minion.yml
    - template: jinja

# Manage Slatstack repo
{% set key_url = 'https://repo.saltproject.io/salt/py3/ubuntu/22.04/amd64/SALT-PROJECT-GPG-PUBKEY-2023.gpg' %}
{% set osname = grains.os|lower %}
{% set oscodename = grains.oscodename %}
{% if osname == 'raspbian' %}
  {% set os_url = 'https://repo.saltproject.io/py3/debian/' + grains.osrelease + '/' + grains.osarch + '/latest' %}
{% elif grains.osfinger == 'Debian-12' %}
  # Use debian 11 repo. FIXME: update when Debian 12 will be presented
  {% set os_url = 'https://repo.saltproject.io/py3/debian/11/' + grains.osarch + '/latest' %}
  {% set oscodename = 'bullseye' %}
{% else %}
# Repo path
  {% set os_url = 'https://repo.saltproject.io/salt/py3/' + osname + '/' + grains.osrelease + '/' + grains.osarch + '/latest' %}
{% endif %}
saltstack-repo:
  pkgrepo.managed:
    - file: /etc/apt/sources.list.d/saltstack.list
    - name: deb {{ os_url }} {{ oscodename }} main
    - key_url: {{ key_url }}

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

{%endif %}
