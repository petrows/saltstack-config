
# Check that salt-minion installed
{% if salt['file.file_exists']('/lib/systemd/system/salt-minion.service') %}

salt-minion-config:
  file.managed:
    - name: /etc/salt/minion.d/99-pws.conf
    - source: salt://files/servers/salt/minion.yml
    - template: jinja

# Manage Slatstack repo
{% set key_url = 'https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public' %}

saltstack-version:
  file.managed:
    - name: /etc/apt/preferences.d/saltstack-version
    - contents: |
        Package: salt-*
        Pin: version {{ pillar.saltstack.version }}.*
        Pin-Priority: 1001

saltstack-repo:
  pkgrepo.managed:
    - file: /etc/apt/sources.list.d/saltstack.list
    - name: deb https://packages.broadcom.com/artifactory/saltproject-deb/ stable main
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
        export DEBIAN_FRONTEND=noninteractive
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
