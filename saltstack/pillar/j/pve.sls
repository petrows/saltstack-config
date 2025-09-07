# Config for Julia RPI

{% import_yaml 'static.yaml' as static %}
{% import_yaml 'network.yaml' as network %}

timezone: Europe/Moscow

packages:
  - wireguard

check_mk_plugins:
  - smart

pve:
  ssl_certs: pws_secrets:ssl_pws_j_pws

firewall:
  strict_mode: False
  # Redirect local ports from 8006 to 443 for Proxmox web GUI access
  rules_nat_prerouting_v4:
    pve-https-v4: ip daddr {{ network.hosts.j_pve.lan.ipv4.addr }} tcp dport 443 counter redirect to :8006
  rules_nat_prerouting_v6:
    pve-https-v6: ip6 daddr {{ network.hosts.j_pve.lan.ipv6.addr }} tcp dport 443 counter redirect to :8006

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
