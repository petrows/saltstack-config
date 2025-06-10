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
      - openipmi

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

{% if salt['pillar.get']('roles:server-dedicated', False) and salt['pillar.get']('swap_size_mb', 0) > 0 %}
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
    - clients:
    {% for host in export.hosts %}
      - hosts: {{ host.host }}
        options:
      {% for opt in host.opts %}
        - {{ opt }}
      {% endfor %}
    {% endfor %}
    - require:
      - pkg: nfs-packages
{% endfor %}

# Systemd cronjobs?
{% for id, cron in salt['pillar.get']('systemd-cron', {}).items() %}
{% set service_enabled = cron.enable | default(True) %}
{% set service_rnd = cron.randomize | default(60) %}
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
        RandomizedDelaySec={{ service_rnd }}
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

{% if pillar.network.ntp %}
# Configure Systemd-timesync
# It will use DHCP-provided, and we set ours, if not set
/etc/systemd/timesyncd.conf:
  file.managed:
    - contents: |
        # Managed by SALT
        [Time]
        # We leave NTP as default (network-provided) and provide secondary
        FallbackNTP={{ pillar.network.ntp }}
        RootDistanceMaxSec=30
        PollIntervalMinSec=32
        PollIntervalMaxSec=2048
        ConnectionRetrySec=30
        SaveIntervalSec=60
timesyncd-reload:
  cmd.run:
    - shell: /bin/bash
    - name: |
        if systemctl is-enabled systemd-timesyncd.service ; then
          timedatectl set-ntp true
          systemctl restart systemd-timesyncd
        fi
    - onchanges:
      - file: /etc/systemd/timesyncd.conf
{% endif %}

# Dummy file to allow watch
/usr/lib/tmpfiles.d/salt.conf:
  file.managed:
    - contents: ''

systemd-tmpfiles-restart:
  cmd.run:
    - name: systemd-tmpfiles --create
    - onchanges:
      - file: /usr/lib/tmpfiles.d/*.conf

# Netplan config?
{% if pillar.network.netplan %}
# Remove legacy direct config
/etc/systemd/network/10-interface-lan.link:
  file.absent: []
# Remove default ubuntu config file
/etc/netplan/50-cloud-init.yaml:
  file.absent: []
# Our PWS config
{{ pillar.network.netplan_filename }}:
  file.serialize:
    - makedirs: True
    - mode: 600
    - serializer: yaml
    - dataset_pillar: 'network:netplan'
# Test config if changed
netplan-validate:
  cmd.run:
    - name: 'netplan generate'
    - onchanges:
      - file: /etc/netplan/*
{% endif %}

# TMP ramdisk?
{% if pillar.tmp_ramdisk %}
tmp_ramdisk:
  mount.mounted:
    - name: /tmp
    - device: tmpfs
    - fstype: tmpfs
    - mkmnt: True
    - opts:
      - defaults
{% else %}
tmp_ramdisk:
  mount.unmounted:
    - name: /tmp
    - persist: True
{% endif %}

# Prepare apt-key folder
/etc/apt/keyrings:
  file.directory:
    - name: /etc/apt/keyrings
    - user: root
    - group: root
    - mode: 755
# Import new keys in modern APT
{% for key_name, key_url in pillar.apt.keys_import.items() %}
{{ key_name }}-source:
  file.managed:
    - name: /etc/apt/keyrings/{{ key_name }}.source
    - source: {{ key_url }}
    - skip_verify: True
{{ key_name }}-import:
  cmd.wait:
    - name: |
        rm -rf /etc/apt/keyrings/{{ key_name }}.gpg
        cat /etc/apt/keyrings/{{ key_name }}.source | gpg --dearmor -o /etc/apt/keyrings/{{ key_name }}.gpg
    - watch:
      - file: /etc/apt/keyrings/{{ key_name }}.source
{% endfor %}
