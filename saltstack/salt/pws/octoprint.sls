# Prepare deps
update-octopi-files:
  file.recurse:
    - name: /home/pi
    - source: salt://files/octoprint/pi/
    - template: jinja
    - user: pi
    - group: pi

# Install required packages into Octoprint venv
update-octopi-env:
  cmd.run:
    - cwd: /home/pi/oprint
    - runas: pi
    - shell: /bin/bash
    - name: |
        set -e
        # Configure venv
        source ./bin/activate
        # Install reqs
        pip3 install -r /home/pi/requirements.txt
        # Save current verion, to flag last used
        cp -v /home/pi/requirements.txt /home/pi/requirements.txt.installed
    - unless:
      # Check that file is up-to-date
      - cmp -s /home/pi/requirements.txt /home/pi/requirements.txt.installed
