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
    - name: /usr/share/applications/firefox.desktop
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

# Apply XDG settings
firefox-xdg:
  cmd.run:
    - name : |
        xdg-settings set default-web-browser firefox.desktop
        xdg-settings set default-url-scheme-handler http firefox.desktop
        xdg-settings set default-url-scheme-handler https firefox.desktop
    - unless:
      - xdg-settings get default-web-browser | grep firefox
      - xdg-settings get default-url-scheme-handler http | grep firefox
      - xdg-settings get default-url-scheme-handler https | grep firefox

# Apply apparmor config
/etc/apparmor.d/firefox-local:
  file.managed:
    - contents: |
        # This profile allows everything and only exists to give the
        # application a name instead of having the label "unconfined"
        abi <abi/4.0>,
        include <tunables/global>
        profile firefox-local /opt/firefox/{firefox,firefox-bin,updater} flags=(unconfined) {
            userns,
            # Site-specific additions and overrides. See local/README for details.
            include if exists <local/firefox>
        }
