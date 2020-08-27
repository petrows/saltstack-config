linux-base-packages:
  pkg.installed:
    - pkgs:
      - software-properties-common
      {% if grains.osfinger != 'Debian-8' %}
      - ack
      - python3-git
      {% endif %}
      - htop
      - strace
      - vim
      - ethtool
      - net-tools
      - mailutils
      - git
      - python2.7
      - python3
      - python3-pip
      - curl
      - wget
      - screen
      - mc

linux-autoupgrade-packages:
  pkg.installed:
    - pkgs:
      - unattended-upgrades

{% for pkg in salt.pillar.get('packages', []) %}
linux-add-package-{{ pkg }}:
  pkg.installed:
    - name: {{ pkg }}
{% endfor %}
