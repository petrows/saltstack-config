# Common / Additional scripts for all hosts

system-custom-bin:
  file.recurse:
    - name: /usr/local/bin
    - source: salt://files/linux-config/scripts/bin
    - template: jinja
    - file_mode: 755

system-custom-sbin:
  file.recurse:
    - name: /usr/local/sbin
    - source: salt://files/linux-config/scripts/sbin
    - template: jinja
    - file_mode: 755
