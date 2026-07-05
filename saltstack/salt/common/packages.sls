linux-base-packages:
  pkg.installed:
    - pkgs:
      - software-properties-common
      - ack
      - htop
      - strace
      - vim
      - ethtool
      - net-tools
      - mailutils
      - git
      - python3
      - python3-git
      - python3-pip
      - python3-requests
      - python3-virtualenv
      - python3-venv
      - python3-yaml
      - python-is-python3
      - curl
      - wget
      - screen
      - mc
      - openssh-server
      - zstd

{% for pkg in salt['pillar.get']('packages', []) %}
linux-add-package-{{ pkg }}:
  pkg.installed:
    - name: {{ pkg }}
{% endfor %}
