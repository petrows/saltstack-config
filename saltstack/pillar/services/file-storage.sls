{% import_yaml 'static.yaml' as static %}

roles:
  - file-storage

include:
  - services.nginx

proxy_vhosts:
  fs:
    domain: fs.petro.ws
    ssl: external
    root: /srv/file-storage
    type: folder
    folder_index: False

systemd-cron:
  fs-cron:
    user: root
    calendar: '*-*-* *:00/30:00'
    cwd: /
    # Remove files older than 14 days
    cmd: find /srv/file-storage/ -mindepth 1 -mtime +14 -delete
