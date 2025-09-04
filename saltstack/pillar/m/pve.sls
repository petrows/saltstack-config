# Config for Julia RPI

{% import_yaml 'static.yaml' as static %}

timezone: Europe/Moscow

check_mk_plugins:
  - smart

kernel-modules:
  nct6775: False

firewall:
  strict_mode: False

pve:
  ssl_certs: pws_secrets:ssl_pws_m_pws

