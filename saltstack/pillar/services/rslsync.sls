roles:
  - rslsync

rslsync:
  download_url: https://download-cdn.resilio.com/stable/linux/x64/0/resilio-sync_x64.tar.gz
  data_dir: /srv/rslsync-data
  user: master
{# Define rslsync instances with:
  instances:
    - user1:
      data_dir: /srv/rslsync-data
      user: master
      port: 8888
#}
