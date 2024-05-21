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
    - clean: True
    - unless:
      # Exatract new archive only if not exists, else leave FF to update it by itself
      - test -d /opt/firefox
  file.directory:
    - name: /opt/firefox
    - user: {{ pillar.firefox.user | default('root') }}
    - group: {{ pillar.firefox.user | default('root') }}
    - recurse:
      - user
      - group

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

{% set browser_def = ['x-www-browser', 'gnome-www-browser'] %}

{% for def in browser_def %}
firefox-def-{{ def }}:
  cmd.run:
    - shell: /bin/bash
    - name: |
        update-alternatives --install /usr/bin/{{ def }} {{ def }} /opt/firefox/firefox 10
        update-alternatives --set {{ def }} /opt/firefox/firefox
    - unless:
      - update-alternatives --query {{ def }} | grep Value | grep --fixed-string '/opt/firefox/firefox'
{% endfor %}
