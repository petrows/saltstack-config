include:
  - common.packages
  - common.fzf
  - common.ssh
  - common.iptables
  - common.python

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

# PWS networks
/etc/pws/networks.json:
  file.managed:
    - name: /etc/pws/networks.json
    - makedirs: True
    - contents: |
        {{ pillar.networks | json }}

{% if salt['pillar.get']('swap_size_mb', 0) %}
coreutils:
  pkg.installed
# Swap file itself
/swap.img:
  cmd.run:
    - name: |
        [ -f /swap.img ] || dd if=/dev/zero of=/swap.img bs=1M count={{ pillar.swap_size_mb }}
        chmod 0600 /swap.img
        mkswap /swap.img
        swapon -a
    - unless:
      - file /swap.img 2>&1 | grep -q "swap file"
  mount.swap:
    - persist: true
{% endif %}

{% if salt['pillar.get']('roles:server-dedicated', False) or salt['pillar.get']('swap_size_mb', 0) %}
# Configure less aggressive swap usage
vm.swappiness:
  sysctl.present:
    - value: 10
{% endif %}

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
{% set service_enabled = cron.enable | default(True) %}
{{ id }}.service:
  file.managed:
    - name: /etc/systemd/system/{{ id }}.service
    - contents: |
        [Unit]
        Description=Systemd cron: {{ id }}
        OnFailure=status-email@%n.service
        [Service]
        User={{ cron.user }}
        Group={{ cron.user }}
        Type=simple
        RemainAfterExit=no
        WorkingDirectory={{ cron.cwd }}
        ExecStart=/bin/bash -c '{{ cron.cmd }}'
{% if service_enabled %}
  service.enabled: []
{% else %}
  service.disabled: []
{% endif %}
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
{% if service_enabled %}
  service.running:
    - enable: True
    - full_restart: True
    - watch:
      - file:  /etc/systemd/system/{{ id }}.timer
{% else %}
  service.dead:
    - enable: False
{% endif %}

{% endfor %}

# Drop APT spam message,
# See: https://forum.checkmk.com/t/mk-apt-and-latest-idea-from-ubuntu/34135
/etc/apt/apt.conf.d/20apt-esm-hook.conf:
  file.absent: []
