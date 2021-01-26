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
        After=network.target
        [Service]
        Type=oneshot
        RemainAfterExit=no
        User=master
        Group=master
        WorkingDirectory=/
        ExecStart=/home/master/bin/instaloader-folder /srv/storage/home/petro/instaloader
        [Install]
        WantedBy=multi-user.target
  service.enabled:
    - enable: True # dummy value

instaloader-petro.timer:
  file.managed:
    - name: /etc/systemd/system/instaloader-petro.timer
    - contents: |
        [Unit]
        Description=Instaloader petro timer
        [Timer]
        Unit=instaloader-petro.service
        OnBootSec=1min
        OnCalendar=*-*-* *:*:00
        [Install]
        WantedBy=timers.target
  service.running:
    - enable: True # dummy value
