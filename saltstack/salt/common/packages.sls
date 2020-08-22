linux-base-packages:
  pkg.installed:
    - pkgs:
      - ack
      - htop
      - strace
      - vim
      - net-tools
      - mailutils
      - git
      - python2.7
      - python3
      - python3-pip
      - python3-git
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
