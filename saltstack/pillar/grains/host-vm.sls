# Config for VM (KVM, Qemu, VMWare, ...)

roles:
  - server-dedicated

{% if salt['grains.get']('virtual:kvm', False) %}
packages:
  - qemu-guest-agent
{% endif %}
