# Standard motherboard modules for sensors

# Config for x86 system
{% if grains.osarch == 'amd64' %}
kernel-modules:
  coretemp: True
  nct6775: True
{% endif %}
