# Set rules to block torrents

{% set block_strings = ["BitTorrent", "peer_id=", ".torrent", "announce.php?passkey=", "torrent", "announce", "get_peers", "info_hash", "find_node"] %}

iptables:
  strings_block:
{% for str in block_strings %}
    bittorrent-{{ loop.index }}:
      algo: bm
      string: "{{ str }}"
{% endfor %}
