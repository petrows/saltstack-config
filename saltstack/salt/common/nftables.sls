# Common actions for NFT Tables firewall

nftables-pkg:
  pkg.installed:
    - pkgs:
      - nftables

# Primary config has to be checked last, because it loads all other files
# and overwrites all if changed

/etc/nftables.conf:
  file.managed:
    - source: salt://files/nftables/nftables.conf
    - user: root
    - group: root
    - mode: 0644
    - makedirs: True
    - template: jinja
    - require:
      - pkg: nftables-pkg

nftables-reload-main:
  cmd.run:
    - name: 'nft -f /etc/nftables.conf'
    - onchanges:
      - file: /etc/nftables.conf
{%- for id, enable in pillar.firewall.include_files.items() %}
{%- if enable %}
      - file: /etc/nftables.d/{{ id }}.nft
{%- endif %}
{%- endfor %}

nftables.service:
  service.enabled:
    - require:
      - pkg: nftables-pkg

# Remove legacy config
iptables-pkg:
  pkg.purged:
    - pkgs:
      - iptables-persistent
/etc/iptables:
  file.absent: []
/etc/nftables.d/pws.nft:
  file.absent: []
