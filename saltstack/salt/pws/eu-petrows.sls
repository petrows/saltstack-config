# Config for Aruba VM

trs-update.service:
  file.managed:
    - name: /etc/systemd/system/trs-update.service
    - contents: |
        [Unit]
        Description=Updates-checker script
        After=network.target
        [Service]
        User=www
        Group=www
        WorkingDirectory=/home/www/petro.ws/trs/web
        ExecStart=/usr/bin/php update.php --feeds
        [Install]
        WantedBy=multi-user.target
  service.enabled:
    - enabled: True

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
  service.running:
    - enable: True

