media-scripts:
  file.recurse:
    - name: /home/master/bin
    - source: salt://files/pws-media/master/bin
    - makedirs: True
    - user: master
    - group: master
    - file_mode: 755
