# Config for Julia RPI

{% import_yaml 'static.yaml' as static %}

timezone: Europe/Moscow

packages:
  - wireguard

check_mk_plugins:
  - smart

firewall:
  strict_mode: False

pve:
  ssl_certs: pws_secrets:ssl_pws_j_pws

# Mount external data storage via USB
mounts:
  j_data:
    name: /mnt/julia-data
    device: /dev/disk/by-id/ata-WDC_WDS100T1R0A-68A4W0_22371A802931-part1
    type: ext4
    opts: defaults

# Backup cronjob
systemd-cron:
  backup-j-pve:
    user: root
    # Every day
    calendar: 'Mon 8:00'
    cwd: /
    cmd: /usr/sbin/backup-j-pve
