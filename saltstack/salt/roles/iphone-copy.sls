# Service to copy / backup iPhones to data folders

/etc/iphone-copy:
  file.directory: []

{% for conf_id, conf in pillar.iphone_copy.items() %}

/usr/local/sbin/iphone-copy-{{ conf_id }}:
  file.managed:
    - mode: 755
    - contents: |
        #!/bin/bash -xe
        # Prepare
        if [[ -d /tmp/iphone-{{ conf_id }} ]]; then
          fusermount -u /tmp/iphone-{{ conf_id }} || true
        else
          mkdir -p /tmp/iphone-{{ conf_id }}
        fi
        # Mount device
        ifuse -o uid={{ conf.uid }},gid={{ conf.uid }} /tmp/iphone-{{ conf_id }}
        # Copy sync
        exif-sort --copy --lastmarker /etc/iphone-copy/{{ conf_id }}.txt /tmp/iphone-{{ conf_id }}/DCIM --out "{{ conf.out_path }}"

{% endfor %}
