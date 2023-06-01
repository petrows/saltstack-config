# SLS to install firefox from binaries

roles:
  - firefox

firefox:
  version: 113.0.2
  # Use root user as default, do not update sudden updates
  user: root
