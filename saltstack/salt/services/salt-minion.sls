
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
{% else %}
# Repo path
  {% set os_url = 'https://repo.saltproject.io/salt/py3/' + osname + '/' + grains.osrelease + '/' + grains.osarch + '/latest' %}
{% endif %}
saltstack-repo:
  pkgrepo.managed:
    - file: /etc/apt/sources.list.d/saltstack.list
    - name: deb {{ os_url }} {{ oscodename }} main
    - key_url: {{ key_url }}
    - clean_file: True

/etc/apt/sources.list.d/salt.list:
  file.absent: []

/usr/sbin/salt-minion-update:
  file.managed:
    - mode: 755
    - contents: |
        #!/bin/bash -x
        # Update software
        apt-get update
        apt-get install --only-upgrade -y -q -o DPkg::Options::="--force-confold" --no-install-recommends salt-minion
        # Update Salt user to OUR defaults
        usermod -d {{ pillar.users.salt.home }} -s {{ pillar.users.salt.shell }} salt

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
