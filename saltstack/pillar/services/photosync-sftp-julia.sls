{% import_yaml 'static.yaml' as static %}
# Pillar to provide SFT backend for PhotoSync app for iPhone
# Version for Julia

photosync-sftp:
  instances:
    julia:
      uid: {{ static.uids.master }}
      port: {{ static.proxy_ports.photosync_sftp_julia }}
      # FIXME: Change me in the future
      dir: /mnt/pws-data/tmp/iPhone-Julia-PhotoSync
