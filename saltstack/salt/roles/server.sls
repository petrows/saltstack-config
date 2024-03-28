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

# Confgure hostname
/etc/hostname:
  file.managed:
    - contents: '{{ grains.id }}'
  cmd.wait:
    - name: hostnamectl set-hostname {{ grains.id }}
    - watch:
      - file: /etc/hostname

# Ask PVE ignore this file (container only)
{% if grains.virtual == 'container' %}
/etc/.pve-ignore.hostname:
  file.managed:
    - contents: ''
{% endif %}

/etc/hosts:
  file.managed:
    - source: salt://files/etc-hosts
    - template: jinja
    - user: root
    - group: root
    - mode: 644
