proxy_vhosts:
  wiki:
    domain: wiki.petro.ws
    ssl: external
  # Local domain - for backup
  wiki_local:
    domain: wiki.web-wm.pws
    port: {{ static.proxy_ports.wiki_http }}
    ssl: internal
    ssl_name: local
