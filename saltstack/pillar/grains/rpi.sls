# Common config for Raspberry PI boards used

# Do not mount tmpfs from RAM (low RAM)
tmp_ramdisk: False

# Swap size is 4Gb for all types of devices
swap_size_mb: {{ 4 * 1024 }}

# Do not upgrade on RPI
upgrades:
  auto: False

# Do not write log data to disk
journald:
  storage: volatile
