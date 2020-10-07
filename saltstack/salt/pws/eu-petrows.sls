# Config for Aruba VM

trs-update.timer:
  file.managed:
    - name: /etc/systemd/system/trs-update.timer
    - contents: |
        [Unit]
        Description=TRS feed update
        [Timer]
        OnCalendar=*-*-* *:00/5:00
        [Install]
        WantedBy=timers.target
  service.enabled:
    - enabled: True

trs-update.service:
  file.managed:
    - name: /etc/systemd/system/trs-update.service
    - contents: |
        [Unit]
        Description=Updates-checker script
        After=network.target
        [Service]
        User=root
        Group=root
        WorkingDirectory=/home/www/petro.ws/trs
        ExecStart=/usr/bin/php update.php
        [Install]
        WantedBy=multi-user.target
  service.enabled:
    - enabled: True

