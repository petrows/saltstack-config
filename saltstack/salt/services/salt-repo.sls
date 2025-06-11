# Manage Slatstack repo

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
        Signed-By: /etc/apt/keyrings/saltstack.gpg
        Suites: stable
        Components: main
