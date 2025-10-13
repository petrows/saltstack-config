# Tuxedo laptop config

roles:
  - tuxedo

# Apt options
apt:
  # What keys to import for 3rd-party repos
  keys_import:
    tuxedo:
      - https://deb.tuxedocomputers.com/tuxedo.gpg
