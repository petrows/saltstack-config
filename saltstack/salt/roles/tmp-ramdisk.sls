tmp_ramdisk:
  mount.mounted:
    - name: /tmp
    - device: tmpfs
    - fstype: tmpfs
    - mkmnt: True
    - opts:
      - defaults
