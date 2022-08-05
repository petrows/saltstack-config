{% import_yaml 'static.yaml' as static %}

roles:
  - mounts
  - integrity_client

check_mk_plugins:
  - smart
  - lvm
  - apcaccess
  - mk_logwatch.py

integrity:
  check_targets:
    pve: True

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


# Mount external data storage for DMZ host
mounts:
  pws_data:
    name: /srv/pws-data
    device: /dev/mapper/data_vg-pws--data
    type: ext4
    opts: defaults
  pws_cache:
    name: /srv/pws-cache
    device: /dev/mapper/cache_vg-pws--cache
    type: ext4
    opts: defaults
  pws_media:
    name: /srv/pws-media
    device: /dev/mapper/media_vg-pws--media
    type: ext4
    opts: defaults

nfs-exports:
  media:
    path: /srv/pws-media/media/video
    hosts: '10.80.0.12'
    opts:
     - ro
     - sync
     - insecure
     - no_root_squash
     - no_subtree_check

# Backup service
ssh:
  keys:
    root@pve.office.pws:
      user: root
      enc: ssh-rsa
      key: AAAAB3NzaC1yc2EAAAADAQABAAABAQDDGwWMJRn946rItla9U4vmM19AlVqWFhQtWnhXetRKnc84RXN4YhLz6jatDqcLHzeghx1EnbfF/1GXYZ77XOEoEz25QiSoHjk3euAGLa4csnqgQACwlt42sqpcflXRnI/TWj/ULHgUEehmSDEnyjlVC3W51JgK+RVY9A/XZYWs5Smf3UIT0pL5ndFEKHtxcwEdUiKMG0Ale6MAa17x2O05wHHhcKLYvXyfL9TAF4RCpClfvjN55Q6BpuSZLcCfK7PY7iKpLsD96NwUyd9wwg2IvCJxMduqrG38Q7wwCDEq0wWK2Mno4QoJVNqZKH67ff9d10XtDAwiqv2VbLx3bDGv
