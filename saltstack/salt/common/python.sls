# Applications python env

# Interpreter: /opt/venv/app/bin/python

# Prepare venv
/opt/venv/app:
  virtualenv.managed:
    - user: root
    - python: {{ pillar.python_system_bin }}
    - pip_pkgs:
      {% for pkg in pillar.packages_pip3 %}
      - {{ pkg }}
      {% endfor %}

# Default interpreter
/usr/bin/python-app:
  file.managed:
    - mode: 755
    - follow_symlinks: false
    - contents: |
        #!/bin/bash -e
        source /opt/venv/app/bin/activate
        /opt/venv/app/bin/python "$@"
