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
