{% import_yaml 'static.yaml' as static %}
{% set is_ct = (grains.get('virtual') == 'container') %}

roles:
  - k8s-worker

# VM only
{% if not is_ct %}
# Mount 2nd disk as /srv for Longhorn driver
mounts:
  srv:
    name: /srv/
    device: /dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi1
    type: ext4
    opts: rw,noexec,nosuid
{% endif %}
