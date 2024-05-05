{% import_yaml 'static.yaml' as static %}

paperless:
  id: Paperless

proxy_vhosts:
  paperless:
    domain: docs.media.pws
    port: {{ static.proxy_ports.paperless_http }}
    ssl: internal
    ssl_name: media
