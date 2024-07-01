scan-scripts:
  file.recurse:
    - name: /usr/local/bin
    - source: salt://files/scan/bin
    - makedirs: True
    - file_mode: 755
