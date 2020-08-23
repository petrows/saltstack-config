{% import_yaml 'static.yaml' as static %}

check_mk_plugins:
  - smart
  - lvm
  - apcaccess
  - mk_logwatch

swap_size_mb: {{ 4 * 1024 }}

# VM configs
pve_vms_config:
  {{ static.vm_ids.media }}:
    - 'mp0: /srv/hdd2/media,mp=/srv/media'
    - 'mp1: /srv/pws-data/storage,mp=/srv/storage'
    - 'mp2: /srv/pws-data/storage-old,mp=/srv/storage-old'
    - 'mp3: /srv/pws-data/share,mp=/srv/share'
    - 'mp4: /srv/pws-data/tmp,mp=/srv/storage-tmp'
  {{ static.vm_ids.fabian }}:
    - 'mp0: /srv/hdd2/media,mp=/srv/media'
    - 'mp1: /srv/pws-data/tmp,mp=/srv/tmp'
  {{ static.vm_ids.home }}:
    - 'lxc.cgroup.devices.allow: c 188:* rwm'
    - 'lxc.mount.entry: /dev/ttyUSB-Z-Stack dev/ttyUSB-Z-Stack none bind,optional,create=file'
  {{ static.vm_ids.backup }}:
    - 'mp0: /srv/pws-data,mp=/mnt/pws-data'
    - 'mp1: /srv/hdd2,mp=/mnt/hdd2'
