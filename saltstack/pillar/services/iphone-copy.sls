# Service to copy / backup iPhones to data folders

{% import_yaml 'static.yaml' as static %}

roles:
  - iphone-copy

iphone_copy:
  julia:
    serial: 0000811000110C5A0150401E
    out_path: /mnt/julia-data/storage/Фото/%Y/%Y - Julia iPhone
    uid: {{ static.uids.master }}
