{% import_yaml 'static.yaml' as static %}

check_mk_plugins:
  - smart
  - lvm
  - apcaccess
  - mk_logwatch

swap_size_mb: {{ 4 * 1024 }}

# VM configs
pve_vms_config:
  {{ static.vm_ids.home }}:
    - 'lxc.cgroup.devices.allow: c 188:* rwm'
    - 'lxc.mount.entry: /dev/ttyUSB-Z-Stack dev/ttyUSB-Z-Stack none bind,optional,create=file'
