{% import_yaml 'static.yaml' as static %}

proxy_vhosts:
  wiki:
    domain: wiki.petro.ws
    ssl: external
  # Local domain - for backup
  wiki_local:
    domain: wiki.web-vm.pws
    port: {{ static.proxy_ports.wiki_http }}
    ssl: internal
    ssl_name: local
