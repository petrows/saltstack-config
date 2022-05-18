firefox-cleanup:
  pkg.removed:
    - pkgs:
      - firefox

firefox-extract:
  archive.extracted:
    - name: /opt
    - source: https://download-installer.cdn.mozilla.net/pub/firefox/releases/{{ pillar.firefox.version }}/linux-x86_64/en-US/firefox-{{ pillar.firefox.version }}.tar.bz2
    - skip_verify: True
    - enforce_toplevel: False

firefox-binary:
  file.symlink:
    - name: /usr/local/bin/firefox
    - target: /opt/firefox/firefox
    - force: True
    - require:
      - archive: firefox-extract

firefox-desktop:
  file.managed:
    - name: /usr/local/share/applications
    - source: salt://files/firefox/firefox.desktop
