# pve.office.pws

# Backup script
pve-office-backup:
  file.managed:
    - name: /usr/sbin/pws-backup-remote
    - mode: 755
    - contents: |
        #!/bin/bash -xe
        BACKUP_HOST=root@pve.pws
        ssh $BACKUP_HOST mount /dev/mapper/backup_vg-pws--backup /srv/backup/ || true
        mount /dev/backup_remote_vg/pws-backup-remote /srv/backup || true
        rsync -rva --delete $BACKUP_HOST:/srv/backup/daily/daily.0/ /srv/backup/pve-backup/
        umount /srv/backup
        ssh $BACKUP_HOST umount /srv/backup/ || true

pve-remote-backup.service:
  file.managed:
    - name: /etc/systemd/system/pve-remote-backup.service
    - contents: |
        [Unit]
        Description=PVE backup remote service
        [Service]
        Type=oneshot
        RemainAfterExit=no
        ExecStart=/usr/sbin/pws-backup-remote
        TimeoutStartSec=0
  service.disabled: []

pve-remote-backup.timer:
  file.managed:
    - name: /etc/systemd/system/pve-remote-backup.timer
    - contents: |
        [Unit]
        Description=PVE backup remote timer
        [Timer]
        OnCalendar=*-*-* 5:00:00
        RandomizedDelaySec=60
        [Install]
        WantedBy=timers.target
  service.running:
    - enable: True

