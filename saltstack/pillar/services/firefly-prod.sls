firefly:
  id: Firefly

# Production config does not have it's own nginx proxy config,
# managed by external web frontend

proxy_vhosts:
  firefly_importer:
    domain: import.bank.pws
    ssl: internal
    ssl_name: bank
