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

