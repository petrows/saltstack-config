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
      - python3
      - python3-pip
      - python3-virtualenv
      {% if grains.osfinger == 'Raspbian-10' %}
      # RPi requires special package for virtualenv
      - virtualenv
      {% endif %}
      - curl
      - wget
      - screen
      - mc
      - openssh-server

{% for pkg in salt['pillar.get']('packages', []) %}
linux-add-package-{{ pkg }}:
  pkg.installed:
    - name: {{ pkg }}
{% endfor %}
