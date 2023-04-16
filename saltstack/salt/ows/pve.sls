# pve.ows

pve-udev:
  file.managed:
    - name: /etc/udev/rules.d/10-local.rules
    - contents: |
        # Add USB Z-Stack stick as special device to be provided by VM
        # To get current attrs use command:
        # udevadm info -a -p  (udevadm info -q path -n /dev/ttyUSB0)
        # usb 2-6: new full-speed USB device number 2 using xhci_hcd
        # usb 2-6: New USB device found, idVendor=1a86, idProduct=7523, bcdDevice= 2.54
        # usb 2-6: New USB device strings: Mfr=0, Product=2, SerialNumber=0
        # usb 2-6: Product: USB2.0-Serial
        SUBSYSTEMS=="usb", KERNEL=="ttyUSB*", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", SYMLINK+="ttyUSB-Z-Stack", MODE="0666", GROUP="dialout"

# Backup script
{# pve-office-backup:
  file.managed:
    - name: /usr/sbin/pws-backup-remote
    - mode: 755
    - contents: |
        #!/bin/bash -xe
        BACKUP_HOST=root@pve.pws
        ssh $BACKUP_HOST mount /dev/mapper/backup_vg-pws--backup /srv/backup/ || true
        mount /dev/backup_remote_vg/pws-backup-remote /srv/backup || true
        systemd-notify --ready
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
        Type=notify
        RemainAfterExit=no
        ExecStart=/usr/sbin/pws-backup-remote
        TimeoutStartSec=0
        [Install]
        WantedBy=
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
 #}
