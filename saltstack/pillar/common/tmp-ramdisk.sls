# This SLS defines /tmp to be mounted from RAM
# Auto-select, ON for machines with > 4Gb RAM,
{% set rmadisk_default = True %}
{% if grains.mem_total < 4096 %}
{% set rmadisk_default = False %}
{% endif %}

tmp_ramdisk: {{ rmadisk_default }}
