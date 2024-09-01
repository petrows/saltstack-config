# Config for Aruba VM

# fail2ban service broken on 24.04
fail2ban-cleanup:
  pkg.purged:
    - pkgs:
      - fail2ban

# Unknown file, expected by hosting provider
/root/prov-launcher.sh:
  file.managed:
    - contents: ''
    - mode: 755
