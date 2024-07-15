# Config for VM (KVM, Qemu, VMWare, ...)

roles:
  - server-dedicated
  - server-vm

{% if salt['grains.get']('virtual', None) == 'kvm' %}
packages:
  - qemu-guest-agent
{% endif %}
