media-scripts:
  file.recurse:
    - name: /home/master/bin
    - source: salt://files/pws-media/master/bin
    - makedirs: True
    - user: master
    - group: master
    - file_mode: 755

instaloader-pkg:
  pip.installed:
    - pkgs:
      - instaloader
    - bin_env: {{ pillar.pip3_bin }}

instaloader-petro.service:
  file.managed:
    - name: /etc/systemd/system/instaloader-petro.service
    - contents: |
        [Unit]
        Description=Instaloader petro
        [Service]
        Type=oneshot
        RemainAfterExit=no
        User=master
        Group=master
        WorkingDirectory=/
        ExecStart=/home/master/bin/instaloader-folder /srv/storage/home/petro/instaloader
  service.disabled: []

instaloader-petro.timer:
  file.managed:
    - name: /etc/systemd/system/instaloader-petro.timer
    - contents: |
        [Unit]
        Description=Instaloader petro timer
        [Timer]
        Unit=instaloader-petro.service
        OnCalendar=6,16,23:00:00
        RandomizedDelaySec=3600
  service.running:
    - enable: True

sync-fotos.service:
  file.managed:
    - name: /etc/systemd/system/sync-fotos.service
    - contents: |
        [Unit]
        Description=Sync fotos
        After=network.target
        [Service]
        Type=oneshot
        RemainAfterExit=no
        User=master
        Group=master
        WorkingDirectory=/
        ExecStart=/home/master/bin/sync-fotos
  service.enabled: []

sync-fotos.timer:
  file.managed:
    - name: /etc/systemd/system/sync-fotos.timer
    - contents: |
        [Unit]
        Description=Sync fotos timer
        [Timer]
        Unit=sync-fotos.service
        OnCalendar=06:00:00
        RandomizedDelaySec=3600
        [Install]
        WantedBy=timers.target
  service.running:
    - enable: True

