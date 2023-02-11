# Common config for Raspberry PI boards used

# Do not mount tmpfs from RAM (low RAM)
tmp_ramdisk: False

# Swap size is 4Gb for all types of devices
swap_size_mb: {{ 4 * 1024 }}
