{% import_yaml 'static.yaml' as static %}

roles:
  - docker
  - nginx
  - wiki

wiki:
  version: 1.34.1
  dirs:
    - /opt/wiki-data/images
    - /opt/wiki-data/extensions
    - /opt/wiki-data/uploads

proxy_vhosts:
  wiki:
    domain: wiki-dev.local.pws
    port: {{ static.proxy_ports.wiki_http }}
    ssl: internal
    ssl_name: local
