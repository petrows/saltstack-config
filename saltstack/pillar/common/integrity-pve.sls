# Integrity check
# Detect FS corruption / encryption

# Define cryptor honeypots
integrity:
  pve:
    target: root@pve.pws
    list:
      - path: /srv/pws-data/storage/home/marina/DIRECTORY.txt
        hash: c5e6a97e30859f458542fd25726b3371
        uid: 2017
      - path: /srv/pws-data/storage/home/petro/DIRECTORY.txt
        hash: c5e6a97e30859f458542fd25726b3371
        uid: 2017
      - path: /srv/pws-data/storage-old/archive-old/2007/DIRECTORY.txt
        hash: c5e6a97e30859f458542fd25726b3371
        uid: 2017
      - path: /srv/pws-data/storage/common/archive/2017/DIRECTORY.txt
        hash: c5e6a97e30859f458542fd25726b3371
        uid: 2017
      - path: '/srv/pws-data/storage/common/photo/photos/2020/2020\ -\ Mobile\ Petro/2020-01/IMG_20200118_162512.jpg'
        hash: ed0d6e003bfff751da22c6c6d7a6a3bf
        uid: 2017
