# Config for Julia RPI

{% import_yaml 'static.yaml' as static %}
{% import_yaml 'network.yaml' as network %}

timezone: Europe/Moscow

check_mk_plugins:
  - smart

kernel-modules:
  nct6775: False

pve:
  ssl_certs: pws_secrets:ssl_pws_m_pws

firewall:
  strict_mode: False
  # Redirect local ports from 8006 to 443 for Proxmox web GUI access
  rules_nat_prerouting_v4:
    pve-https-v4: ip daddr {{ network.hosts.m_pve.lan.ipv4.addr }} tcp dport 443 counter redirect to :8006
  rules_nat_prerouting_v6:
    pve-https-v6: ip6 daddr {{ network.hosts.m_pve.lan.ipv6.addr }} tcp dport 443 counter redirect to :8006
