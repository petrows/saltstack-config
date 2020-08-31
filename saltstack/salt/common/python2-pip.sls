python2-pip-python:
  pkg.installed:
    - pkgs:
      - curl
      - python2.7

python2-pip-install:
  cmd.run:
    - name: |
        curl https://bootstrap.pypa.io/get-pip.py --output /tmp/get-pip.py
        python2.7 /tmp/get-pip.py --prefix /usr/local/
        rm -rf /tmp/get-pip.py
    - unless: which pip
    - require:
      - pkg: python2-pip-python
