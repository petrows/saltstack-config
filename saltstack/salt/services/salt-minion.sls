
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

/etc/apt/sources.list.d/saltstack.list:
  file.absent: []

/etc/apt/sources.list.d/salt.list:
  file.absent: []

/etc/apt/keyrings/salt-archive-keyring.pgp.source:
  file.managed:
    - source: https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public
    - skip_verify: True

salt-keyring-import:
  cmd.wait:
    - name: cat /etc/apt/keyrings/salt-archive-keyring.pgp.source | gpg --dearmor > /etc/apt/keyrings/salt-archive-keyring.pgp
    - watch:
      - file: /etc/apt/keyrings/salt-archive-keyring.pgp.source

/etc/apt/sources.list.d/salt.sources:
  file.managed:
    - contents: |
        X-Repolib-Name: Salt Project
        Description: Salt has many possible uses, including configuration management.
          Built on Python, Salt is an event-driven automation tool and framework to deploy,
          configure, and manage complex IT systems. Use Salt to automate common
          infrastructure administration tasks and ensure that all the components of your
          infrastructure are operating in a consistent desired state.
          - Website: https://saltproject.io
          - Public key: https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public
        Enabled: yes
        Types: deb
        URIs: https://packages.broadcom.com/artifactory/saltproject-deb
        Signed-By: /etc/apt/keyrings/salt-archive-keyring.pgp
        Suites: stable
        Components: main

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

{% endif %}
