cctv-timelapse-pkg:
  pkg.installed:
    - pkgs:
      - ffmpeg
/srv/cctv-timelapse:
  file.directory:
    - user: master
    - group: master
    - mode: 755
    - makedirs: True

/srv/cctv-timelapse/data:
  file.directory:
    - user: master
    - group: master
    - mode: 755
    - makedirs: True

/srv/cctv-timelapse/cctv-timelapse.yaml:
  file.serialize:
    - makedirs: True
    - mode: 600
    - user: master
    - group: master
    - serializer: yaml
    - dataset_pillar: 'cctv-timelapse:config'

/usr/bin/cctv-timelapse:
  file.managed:
    - source: salt://files/cctv-timelapse/cctv_timelapse.py
    - mode: 755

/usr/bin/cctv-generate:
  file.managed:
    - source: salt://files/cctv-timelapse/cctv-generate
    - mode: 755

cctv-timelapse.service:
  file.managed:
    - name: /etc/systemd/system/cctv-timelapse.service
    - contents: |
        [Unit]
        Description=CCTV Timelapse
        OnFailure=status-email@%n.service
        [Service]
        User=master
        Group=master
        Type=simple
        RemainAfterExit=no
        ExecStart=/usr/bin/cctv-timelapse --one-shot --config /srv/cctv-timelapse/cctv-timelapse.yaml
  service.enabled:
    - enable: True

cctv-timelapse.timer:
  file.managed:
    - name: /etc/systemd/system/cctv-timelapse.timer
    - contents: |
        [Unit]
        Description=CCTV Timelapse timer
        [Timer]
        OnCalendar=*:00:00
        Unit=cctv-timelapse.service
        [Install]
        WantedBy=timers.target
  service.running:
    - enable: True

cctv-timelapse-generate.service:
  file.managed:
    - name: /etc/systemd/system/cctv-timelapse-generate.service
    - contents: |
        [Unit]
        Description=CCTV Timelapse Video generator
        OnFailure=status-email@%n.service
        [Service]
        User=master
        Group=master
        Type=simple
        RemainAfterExit=no
        ExecStart=/usr/bin/cctv-generate /srv/cctv-timelapse/data /mnt/pws-data/storage/common/photo/photos/
  service.enabled:
    - enable: True

cctv-timelapse-generate.timer:
  file.managed:
    - name: /etc/systemd/system/cctv-timelapse-generate.timer
    - contents: |
        [Unit]
        Description=CCTV Timelapse Video generator timer
        [Timer]
        OnCalendar=23:50:00
        Unit=cctv-timelapse-generate.service
        [Install]
        WantedBy=timers.target
  service.running:
    - enable: True
