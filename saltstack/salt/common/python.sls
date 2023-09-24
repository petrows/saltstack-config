# Applications python env

# Interpreter: /opt/venv/app/bin/python

# Prepare venv
/opt/venv/app:
  virtualenv.managed:
    - user: root
    - pip_pkgs:
      {% for pkg in pillar.packages_pip3 %}
      - {{ pkg }}
      {% endfor %}

# Default interpreter
/usr/bin/python-app:
  file.symlink:
    - target: /opt/venv/app/bin/python
