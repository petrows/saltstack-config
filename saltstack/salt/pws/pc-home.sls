pws-backup-petro-pc.service:
  file.managed:
    - name: /etc/systemd/system/pws-backup-petro-pc.service
    - contents: |
        [Unit]
        Description=Backup local PC
        After=network-online.target
        Wants=network-online.target
        OnFailure=status-email@%n.service
        [Install]
        WantedBy=multi-user.target
        [Service]
        Type=oneshot
        RemainAfterExit=no
        User=petro
        Group=petro
        WorkingDirectory=/
        ExecStart=/usr/local/sbin/pws-backup-pc
  service.enabled:
    - enable: True # dummy value

pws-backup-petro-pc.timer:
  file.managed:
    - name: /etc/systemd/system/pws-backup-petro-pc.timer
    - contents: |
        [Unit]
        Description=Backup local PC timer
        [Timer]
        Unit=pws-backup-petro-pc.service
        OnCalendar=00/3:00:00
        RandomizedDelaySec=3600
        [Install]
        WantedBy=timers.target
  service.running:
    - enable: True # dummy value

