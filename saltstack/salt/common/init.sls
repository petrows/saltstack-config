include:
  - common.packages
  - common.fzf
  - common.ssh
  - common.iptables

locale-us:
  locale.present:
    - name: en_US.UTF-8

ru_RU.UTF-8:
  locale.present

de_DE.UTF-8:
  locale.present

locale-default:
  locale.system:
    - name: en_US.UTF-8
    - require:
      - locale: locale-us

default-timezone:
  timezone.system:
    - name: {{ pillar.timezone }}

ban-packages:
  pkg.purged:
    - pkgs:
      - cloud-init

# PWS root CA
pws-root-ca:
  file.managed:
    - name: /usr/local/share/ca-certificates/pws.ca.crt
    - source: salt://files/pws.ca.crt

system-ca-update:
  cmd.run:
    - name: update-ca-certificates
    - onchanges:
      - file: /usr/local/share/ca-certificates/*

{% if salt['pillar.get']('swap_size_mb', 0) %}
coreutils:
  pkg.installed
# Swap file itself
/swap.img:
  cmd.run:
    - name: |
        [ -f /swapfile ] || dd if=/dev/zero of=/swap.img bs=1M count={{ pillar.swap_size_mb }}
        chmod 0600 /swap.img
        mkswap /swap.img
        swapon -a
    - unless:
      - file /swap.img 2>&1 | grep -q "Linux/i386 swap"
  mount.swap:
    - persist: true
{% endif %}

{% if salt['pillar.get']('roles:server-dedicated', False) or salt['pillar.get']('swap_size_mb', 0) %}
# Configure less aggressive swap usage
vm.swappiness:
  sysctl.present:
    - value: 10
{% endif %}

# Additional scripts
system-custom-bin:
  file.recurse:
    - name: /usr/local/sbin
    - source: salt://files/linux-config/sbin
    - template: jinja
    - file_mode: 755

# Sysctl magic
{% for name, value in salt['pillar.get']('sysctl', {}).items() %}
{{ name }}:
  sysctl.present:
    - value: {{ value }}
{% endfor %}

{% for name, value in salt['pillar.get']('kernel-modules', {}).items() %}
{% if value %}
{{ name }}:
  kmod.present:
    - persist: True
    - mods:
      - {{ name }}
{% endif %}
{% endfor %}

# NFS exports
{% if salt['pillar.get']('nfs-exports', {}) %}
nfs-packages:
  pkg.installed:
    - pkgs:
      - nfs-kernel-server
{% endif %}
{% for id, export in salt['pillar.get']('nfs-exports', {}).items() %}
nfs-export-{{ id }}:
  nfs_export.present:
    - name: {{ export.path }}
    - hosts: {{ export.hosts }}
    - options:
    {% for opt in export.opts %}
      - {{ opt }}
    {% endfor %}
    - require:
      - pkg: nfs-packages
{% endfor %}

# Systemd cronjobs?
{% for id, cron in salt['pillar.get']('systemd-cron', {}).items() %}
{{ id }}.service:
  file.managed:
    - name: /etc/systemd/system/{{ id }}.service
    - contents: |
        [Unit]
        Description=Systemd cron: {{ id }}
        [Service]
        User={{ cron.user }}
        Group={{ cron.user }}
        Type=simple
        RemainAfterExit=no
        WorkingDirectory={{ cron.cwd }}
        ExecStart=/bin/bash -c '{{ cron.cmd }}'
  service.enabled:
    - enabled: True
{{ id }}.timer:
  file.managed:
    - name: /etc/systemd/system/{{ id }}.timer
    - contents: |
        [Unit]
        Description=Systemd cron timer: {{ id }}
        [Timer]
        OnCalendar={{ cron.calendar }}
        RandomizedDelaySec=60
        [Install]
        WantedBy=timers.target
  service.running:
    - enable: True
    - full_restart: True
    - watch:
      - file:  /etc/systemd/system/{{ id }}.timer
{% endfor %}
