{% import_yaml 'static.yaml' as static %}

roles:
  - mounts
  - integrity_client

check_mk_plugins:
  - lvm
  - apcaccess
  - mk_logwatch.py

check_mk_local:
  - backup_stats

integrity:
  check_targets:
    pve: True

swap_size_mb: {{ 4 * 1024 }}

pve:
  ssl_certs: pws_secrets:ssl_pws_pve

# VM configs
pve_vms_config:
  {{ static.vm_ids.media }}:
    - 'mp0: /srv/hdd2/media,mp=/mnt/pws-media/media'
    - 'mp1: /srv/pws-data/storage,mp=/mnt/pws-data/storage'
    - 'mp2: /srv/pws-data/storage-old,mp=/mnt/pws-data/storage-old'
    - 'mp3: /srv/pws-data/share,mp=/mnt/pws-data/share'
    - 'mp4: /srv/pws-data/tmp,mp=/mnt/pws-data/tmp'
  {{ static.vm_ids.fabian }}:
    - 'mp0: /srv/hdd2/media,mp=/mnt/pws-media/media'
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
    opts: rw,noexec,nosuid
  pws_cache:
    name: /srv/pws-cache
    device: /dev/mapper/cache_vg-pws--cache
    type: ext4
    opts: rw,noexec,nosuid,discard
  pws_media:
    name: /srv/pws-media
    device: /dev/mapper/media_vg-pws--media
    type: ext4
    opts: rw,noexec,nosuid

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
    root@backup-ext.pws:
      user: root
      enc: ssh-ed25519
      key: AAAAC3NzaC1lZDI1NTE5AAAAIMUGSf5BBIGEyq4skMbg3H4dqqCn3Adw9E56E1lYC9Ij
