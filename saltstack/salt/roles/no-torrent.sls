
{% set block_strings = ["BitTorrent", "peer_id=", ".torrent", "announce.php?passkey=", "torrent", "announce", "get_peers", "info_hash", "find_node"] %}
{% set ipf = ['ipv4', 'ipv6'] %}

/usr/local/sbin/no-torrent:
  file.managed:
    - mode: 755
    - contents: |
        #!/bin/bash

        iptables-legacy -N NO-TORRENT
        iptables-legacy -F NO-TORRENT

        iptables-legacy -t filter -D FORWARD -j NO-TORRENT
        iptables-legacy -t filter -A FORWARD -j NO-TORRENT

        {% for str in block_strings %}
        iptables-legacy --wait -t filter -A NO-TORRENT -m string --algo bm --string "{{ str }}" -m comment --comment "Block: {{ str }}" --jump DROP
        {% endfor %}

no-torrent.service:
  file.managed:
    - name: /etc/systemd/system/no-torrent.service
    - contents: |
        [Unit]
        Description=Bclock BitTorrent traffic
        After=network.target
        OnFailure=status-email@%n.service
        [Service]
        Type=oneshot
        RemainAfterExit=yes
        User=root
        Group=root
        WorkingDirectory=/
        ExecStart=/usr/local/sbin/no-torrent
        [Install]
        WantedBy=multi-user.target
  service.enabled: []
  cmd.wait:
    - name: systemctl restart no-torrent.service
    - watch:
      - file: /etc/systemd/system/no-torrent.service
      - file: /usr/local/sbin/no-torrent
