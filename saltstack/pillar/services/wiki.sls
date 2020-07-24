{% import_yaml 'static.yaml' as static %}

roles:
  - docker
  - wiki

wiki:
  version: 1.34.1
  dirs:
    - /opt/wiki/images
    - /opt/wiki/extensions
    - /opt/wiki/uploads

proxy_vhosts:
  wiki:
    domain: wiki.petro.ws
    port: {{ static.proxy_ports.wiki_http }}
    ssl: external
