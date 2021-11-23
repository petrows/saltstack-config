# Salt for office RPI

/etc/cups/cupsd.conf:
  file.managed:
    - source: salt://files/rpi.office/cups/cupsd.conf

cups.service:
  service.running:
    - enable: True
    - watch:
      - file: /etc/cups/*

{# /etc/samba/samba.conf:
  file.managed:
    - contents: |
        [global]
          log file = /var/log/samba/log.%m
          max log size = 1000
          logging = file
          panic action = /usr/share/samba/panic-action %d
          server role = standalone server
          obey pam restrictions = yes
          unix password sync = yes
          map to guest = bad user
          log level = 3
          wins support = yes
          dns proxy = yes
          smb ports = 139 445
        [printers]
          comment = All Printers
          browseable = no
          path = /var/spool/samba
          printable = yes
          guest ok = yes
          read only = yes
          create mask = 0700
        [print$]
          comment = Printer Drivers
          path = /var/lib/samba/printers
          browseable = yes
          read only = yes
          guest ok = yes

smbd.service:
  service.running:
    - enable: True
    - watch:
      - file: /etc/samba/* #}
