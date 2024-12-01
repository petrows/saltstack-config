{% import_yaml 'static.yaml' as static %}

roles:
  - k8s-worker

# Mount 2nd disk as /srv for Longhorn driver
mounts:
  srv:
    name: /srv/
    device: /dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi1
    type: ext4
    opts: rw,noexec,nosuid
