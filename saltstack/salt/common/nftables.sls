# Common actions for NFT Tables firewall

nftables-pkg:
  pkg.installed:
    - pkgs:
      - nftables

# Our salt-related config file

/etc/nftables.d/pws.nft:
  file.managed:
    - source: salt://files/nftables/pws.nft
    - user: root
    - group: root
    - mode: 0644
    - makedirs: True
    - template: jinja
    - require:
      - pkg: nftables-pkg

nftables-reload-pws:
  cmd.run:
    - name: 'nft -f /etc/nftables.d/pws.nft'
    - onchanges:
      - file: /etc/nftables.d/pws.nft

# Primary config has to be checked last, because it loads all other files
# and overwrites all if changed

/etc/nftables.conf:
  file.managed:
    - source: salt://files/nftables/nftables.conf
    - user: root
    - group: root
    - mode: 0644
    - makedirs: True
    - require:
      - pkg: nftables-pkg

nftables-reload-main:
  cmd.run:
    - name: 'nft -f /etc/nftables.conf'
    - onchanges:
      - file: /etc/nftables.conf
