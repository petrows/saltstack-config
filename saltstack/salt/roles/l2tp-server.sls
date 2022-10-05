# Role for generic wireguard server

{% set default_if = salt['network.default_route']('inet')[0]['interface'] %}
{% set default_ip = salt['network.ip_addrs'](default_if)[0] %}
{% set server = salt['pillar.get']('l2tp-server', {}) %}
{% set peers =  salt['pillar.get']('pws_secrets:l2tp:'+server.name+':client', {}) %}

l2tp-pkg:
  pkg.installed:
    - pkgs:
      - xl2tpd
      - ppp
      - iptables
      - iptables-persistent

# Deploy server config

/etc/xl2tpd/xl2tpd.conf:
  file.managed:
    - contents: |
        [global]
        port = 1701
        ;debug avp = yes
        ;debug network = yes
        ;debug state = yes
        ;debug tunnel = yes
        [lns default]
        ip range = {{ server.range }}
        local ip = {{ server.address }}
        ;refuse pap = yes
        require authentication = yes
        ;ppp debug = yes
        pppoptfile = /etc/ppp/options.xl2tpd
        length bit = yes

/etc/ppp/options.xl2tpd:
  file.managed:
    - contents: |
        logfd 2
        logfile /var/log/xl2tpns.log
        ;refuse-mschap-v2
        ;refuse-mschap
        ms-dns 8.8.8.8
        ms-dns 8.8.4.4
        asyncmap 0
        auth
        crtscts
        idle 1800
        mtu 1200
        mru 1200
        lock
        hide-password
        local
        #debug
        name l2tpd
        proxyarp
        lcp-echo-interval 30
        lcp-echo-failure 4

/etc/ppp/chap-secrets:
  file.managed:
    - contents: |
        {%- for peer_id, peer in peers.items() %}
        {{ peer.username }} * {{ peer.password }} *
        {%- endfor %}

xl2tpd.service:
  service.running:
    - enable: True
    - watch:
      - file: /etc/ppp/*
      - file: /etc/xl2tpd/*

l2tp-input:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - protocol: udp
    - dport: 1701
    - comment: "L2TP"
    - save: True

l2tp-masquerade:
  iptables.append:
    - table: nat
    - chain: POSTROUTING
    - jump: MASQUERADE
    - out-interface: {{ default_if }}
    - save: True

l2tp-masquerade-sysctl:
  sysctl.present:
    - name: net.ipv4.ip_forward
    - value: 1
