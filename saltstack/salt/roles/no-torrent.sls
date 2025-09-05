
{% set block_strings = ["BitTorrent", "peer_id=", ".torrent", "announce.php?passkey=", "torrent", "announce", "get_peers", "info_hash", "find_node"] %}
{% set ipf = ['ipv4', 'ipv6'] %}


/opt/local/bin/stop-bt.sh:
  file.managed:
    - content: |
        #!/bin/bash

        iptables-legacy -N NO-TORRENT
        iptables-legacy -F NO-TORRENT

        iptables-legacy -t filter -D FORWARD -j NO-TORRENT
        iptables-legacy -t filter -A FORWARD -j NO-TORRENT

        {% for f in ipf %}
        {% for str in block_strings %}
        iptables-legacy --wait -t filter -A FORWARD -m string --algo bm --string "{{ str }}" --jump DROP
        {% endfor %}
        {% endfor %}
