firefly:
  id: Firefly

# Production config has fetch-transactions service
# Do not use on dev!

systemd-cron:
  fetch-transactions-cron:
    enable: True
    user: master
    calendar: '1,12,18:00:00'
    cwd: /srv/bank
    cmd: ./.venv/bin/python bin/fetch-transactions -l DEBUG --cfg-dir /srv/bank/cfg --data-dir /srv/bank/data --days 32
  fetch-transactions-rotate:
    enable: True
    user: master
    # Every 8 hours
    calendar: monthly
    cwd: /srv/bank/data
    cmd: /srv/bank/bin/rotate-data

# Production config does not have it's own nginx proxy config,
# managed by external web frontend

proxy_vhosts:
  firefly_importer:
    domain: import.bank.pws
    ssl: internal
    ssl_name: bank
