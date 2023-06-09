# External backup host

backup-ext-bin:
  file.recurse:
    - name: /usr/local/sbin
    - source: salt://files/backup-ext/bin/
    - template: jinja
    - file_mode: 755

backup-ext.service:
  file.managed:
    - name: /etc/systemd/system/backup-ext.service
    - contents: |
        [Unit]
        Description=Backup ext
        After=network.target
        OnFailure=status-email@%n.service
        [Service]
        ExecStartPre=/bin/sleep 30
        Type=oneshot
        RemainAfterExit=no
        User=root
        Group=root
        WorkingDirectory=/
        ExecStart=/usr/local/sbin/backup-ext
        [Install]
        WantedBy=multi-user.target
  service.enabled: []
