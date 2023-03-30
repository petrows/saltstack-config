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
      - openssh-server

{% for pkg in salt['pillar.get']('packages', []) %}
linux-add-package-{{ pkg }}:
  pkg.installed:
    - name: {{ pkg }}
{% endfor %}

{% for pkg in salt['pillar.get']('packages_pip3', []) %}
linux-add-package-pip3-{{ pkg }}:
  pip.installed:
    - name: {{ pkg }}
    - bin_env: {{ pillar.pip3_bin }}
{% endfor %}
