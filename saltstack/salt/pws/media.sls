media-scripts:
  file.recurse:
    - name: /home/master/bin
    - source: salt://files/pws-media/master/bin
    - makedirs: True
    - user: master
    - group: master
    - file_mode: 755

# instaloader-pkg:
#   pip.installed:
#     - pkgs:
#       - instaloader
#     - bin_env: {{ pillar.pip3_bin }}

# instaloader-petro.service:
#   file.managed:
#     - name: /etc/systemd/system/instaloader-petro.service
#     - contents: |
#         [Unit]
#         Description=Instaloader petro
#         [Service]
#         Type=oneshot
#         RemainAfterExit=no
#         User=master
#         Group=master
#         WorkingDirectory=/
#         ExecStart=/home/master/bin/instaloader-folder /mnt/pws-data/storage/home/petro/instaloader
#   service.disabled: []

# instaloader-petro.timer:
#   file.managed:
#     - name: /etc/systemd/system/instaloader-petro.timer
#     - contents: |
#         [Unit]
#         Description=Instaloader petro timer
#         [Timer]
#         Unit=instaloader-petro.service
#         OnCalendar=6,16,23:00:00
#         RandomizedDelaySec=3600
#   service.disabled: []

sync-fotos.service:
  file.managed:
    - name: /etc/systemd/system/sync-fotos.service
    - contents: |
        [Unit]
        Description=Sync fotos
        After=network.target
        OnFailure=status-email@%n.service
        [Service]
        Type=oneshot
        RemainAfterExit=no
        User=master
        Group=master
        WorkingDirectory=/
        ExecStart=/home/master/bin/sync-fotos 14
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

# Timer and service to watch iPhone sync

sync-fotos-watch.service:
  file.managed:
    - name: /etc/systemd/system/sync-fotos-watch.service
    - contents: |
        [Unit]
        Description=Sync fotos (watch)
        After=network.target
        OnFailure=status-email@%n.service
        [Service]
        Type=notify
        WorkingDirectory=/
        ExecStart=/opt/venv/app/bin/python /usr/local/sbin/file-watch-run -l INFO --delay 60 --folder /mnt/pws-data/storage/home/julia/iPhone-Julia-camera --command "systemctl start sync-fotos.service"
        [Install]
        WantedBy=multi-user.target
  service.running:
    - enable: True
    - watch:
      - file: /etc/systemd/system/sync-fotos-watch.service
