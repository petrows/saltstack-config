{% for d in ['app', 'cfg', 'venv'] %}
{{ pillar.octoprint.home }}/{{ d }}:
  file.directory:
    - user: octoprint
    - group: octoprint
    - dir_mode: 755
{% endfor %}

# Config overlay provision
{{ pillar.octoprint.home }}/cfg/salt.yaml:
  file.serialize:
    - serializer: yaml
    - dataset_pillar: octoprint:cfg

# Application venv
octoprint-venv:
  virtualenv.managed:
    - name: {{ pillar.octoprint.home }}/venv
    - user: octoprint
    - python: {{ pillar.python_system_bin }}
    - pip_pkgs:
      - OctoPrint
      - adafruit-circuitpython-dht==4.0.2

octoprint.service:
  file.managed:
    - name: /etc/systemd/system/octoprint.service
    - contents: |
        [Unit]
        Description=Octoprint
        After=network.target
        OnFailure=status-email@%n.service
        [Service]
        User=octoprint
        Group=octoprint
        WorkingDirectory={{ pillar.octoprint.home }}
        ExecStart={{ pillar.octoprint.home }}/venv/bin/octoprint serve --host localhost --port {{ pillar.octoprint.port }} --basedir {{ pillar.octoprint.home }}/app --overlay {{ pillar.octoprint.home }}/cfg
        [Install]
        WantedBy=multi-user.target
  service.running:
    - enable: True
    - watch:
      - file: /etc/systemd/system/octoprint.service
      - file: {{ pillar.octoprint.home }}/*

octoprint-stream.service:
  file.managed:
    - name: /etc/systemd/system/octoprint-stream.service
    - contents: |
        [Unit]
        Description=Octoprint video stream
        OnFailure=status-email@%n.service
        [Service]
        User=root
        Group=root
        WorkingDirectory={{ pillar.octoprint.home }}
        ExecStart=/usr/bin/ustreamer --host 0.0.0.0 --port {{ pillar.octoprint.stream.port }} --device {{ pillar.octoprint.stream.device }} --resolution {{ pillar.octoprint.stream.resolution }}
        [Install]
        WantedBy=multi-user.target
  service.running:
    - enable: True
    - watch:
      - file: /etc/systemd/system/octoprint-stream.service
      - file: {{ pillar.octoprint.home }}/*

# Klipper application

# Restart klipper firmware on USB (re)connect
/etc/udev/rules.d/98-klipper.rules:
  file.managed:
    - contents: |
        SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", SYMLINK+="klipper_tty", RUN+="/usr/bin/sudo -u octoprint /bin/sh -c '/bin/echo RESTART > {{ pillar.octoprint.klipper.tty }}'"
    - mode: 644

{{ pillar.octoprint.klipper.home }}:
  file.directory:
    - user: octoprint
    - group: octoprint
    - dir_mode: 755
    - makedirs: True

klipper-packages:
  pkg.installed:
    - pkgs:
      - virtualenv
      - python3-dev
      - libffi-dev
      - build-essential
      - libncurses-dev
      - libusb-dev
      - avrdude
      - gcc-avr
      - binutils-avr
      - avr-libc
      - stm32flash
      - dfu-util
      - libnewlib-arm-none-eabi
      - gcc-arm-none-eabi
      - binutils-arm-none-eabi
      - libusb-1.0-0

{{ pillar.octoprint.klipper.home }}/printer.cfg:
  file.managed:
    - source: salt://files/octoprint/klipper/printer.cfg
    - user: octoprint
    - group: octoprint
    - mode: 644
    - makedirs: True

klipper-git:
  git.detached:
    - user: octoprint
    - name: https://github.com/Klipper3d/klipper.git
    - target: {{ pillar.octoprint.klipper.home }}/klipper
    - rev: v{{ pillar.octoprint.klipper.version }}

{{ pillar.octoprint.klipper.home }}/.venv:
  virtualenv.managed:
    - user: octoprint
    - python: {{ pillar.python_system_bin }}
    - requirements: {{ pillar.octoprint.klipper.home }}/klipper/scripts/klippy-requirements.txt
    - watch:
      - git: klipper-git
    - require:
      - pkg: klipper-packages

klipper.service:
  file.managed:
    - name: /etc/systemd/system/klipper.service
    - contents: |
        [Unit]
        Description=Klipper 3D printer firmware
        After=network.target
        OnFailure=status-email@%n.service
        [Service]
        User=octoprint
        Group=octoprint
        WorkingDirectory={{ pillar.octoprint.klipper.home }}
        ExecStart={{ pillar.octoprint.klipper.home }}/.venv/bin/python {{ pillar.octoprint.klipper.home }}/klipper/klippy/klippy.py {{ pillar.octoprint.klipper.home }}/printer.cfg --input-tty={{ pillar.octoprint.klipper.tty }} -l /tmp/klippy.log
        Restart=always
        RestartSec=10
        StartLimitBurst=48
        StartLimitIntervalSec=86400
        [Install]
        WantedBy=multi-user.target
  service.running:
    - enable: True
    - watch:
      - file: /etc/systemd/system/klipper.service
      - file: {{ pillar.octoprint.klipper.home }}/*
      - git: klipper-git
      - virtualenv: {{ pillar.octoprint.klipper.home }}/.venv

# # Prepare deps
# update-octopi-files:
#   file.recurse:
#     - name: {{ pillar.octoprint.home }}
#     - source: salt://files/octoprint/app/
#     - template: jinja
#     - user: pi
#     - group: pi

# # Install required packages into Octoprint venv
# update-octopi-env:
#   cmd.run:
#     - cwd: /home/pi/oprint
#     - runas: pi
#     - shell: /bin/bash
#     - name: |
#         set -e
#         # Configure venv
#         source ./bin/activate
#         # Install reqs
#         pip3 install -r /home/pi/requirements.txt
#         # Save current verion, to flag last used
#         cp -v /home/pi/requirements.txt /home/pi/requirements.txt.installed
#     - unless:
#       # Check that file is up-to-date
#       - cmp -s /home/pi/requirements.txt /home/pi/requirements.txt.installed

# # Replace broken DHT22 script

# dht-read-script:
#   file.recurse:
#     - name: /home/pi/oprint/lib/python3.7/site-packages/octoprint_enclosure/
#     - source: salt://files/octoprint/octoprint_enclosure/
#     - template: jinja
#     - user: pi
#     - group: pi

# TMP: Script to capture water counter

{#
/usr/bin/capture-water:
  file.managed:
    - mode: 755
    - contents: |
        #!/bin/bash -xe

        FDIR=/srv/wz/$(date +"%Y-%m-%d")
        FNAME=$FDIR/$(date +%s).jpg
        FDATE=$(date +"%Y-%m-%d %H:%M:%S")

        mosquitto_pub -h home.pws -u openhabian -P {{ pillar.pws_secrets.openhab.mosquitto_home.password }} -t cmnd/kg_lager1_main_light/POWER -m ON

        sleep 5

        mkdir -p $FDIR
        rm -rf /tmp/wz-*.jpg

        ffmpeg -f video4linux2 -input_format mjpeg -s 2560x1440 -i /dev/video2 -ss 0:0:2 -frames 1 /tmp/wz-out.jpg
        convert /tmp/wz-out.jpg -resize 1024x -rotate 180 $FNAME
        exiftool -overwrite_original -AllDates="$FDATE" $FNAME

        mosquitto_pub -h home.pws -u openhabian -P {{ pillar.pws_secrets.openhab.mosquitto_home.password }} -t cmnd/kg_lager1_main_light/POWER -m OFF
#}
