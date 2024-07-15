
fwupd-refresh.timer:
  service.masked: []

# KVM? Install and start guest agent
{% set is_kvm = salt['grains.get']('virtual', None) == 'kvm' %}

{% if is_kvm %}
kvm-packages:
  pkg.installed:
    - pkgs:
      - qemu-guest-agent

qemu-guest-agent.service:
  service.running:
    - enable: True
  watch:
    - pkg: kvm-packages
{% endif %}
