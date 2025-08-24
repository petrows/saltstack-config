# Common actions for NFT Tables firewall

nftables-pkg:
  pkg.installed:
    - pkgs:
      - nftables

/etc/nftables.conf:
  file.managed:
    - source: salt://files/nftables/nftables.conf
    - user: root
    - group: root
    - mode: 0644
    - makedirs: True
    - require:
      - pkg: nftables-pkg

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
