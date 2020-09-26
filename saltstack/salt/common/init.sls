include:
  - common.packages

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
    - name: Europe/Berlin

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

{% if salt.pillar.get('swap_size_mb', 0) %}
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

{% if salt.pillar.get('roles:server-dedicated', False) or salt.pillar.get('swap_size_mb', 0) %}
# Configure less aggressive swap usage
vm.swappiness:
  sysctl.present:
    - value: 10
{% endif %}
