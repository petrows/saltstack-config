# Drop some packages
server-blacklisted:
  pkg.purged:
    - pkgs:
      - snapd

# Configure Journald
/etc/systemd/journald.conf:
  file.managed:
    - contents: |
        [Journal]
        Storage={{ pillar.journald.storage }}
