{% import_yaml 'static.yaml' as static %}

trss:
  id: Tiny-rss
  url: https://trs.petro.ws

proxy_vhosts:
  trss:
    domain: trs.petro.ws
    ssl: external
