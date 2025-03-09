# Configgure DNS-Over-TLS (DoT)

dot-pkg-old:
  pkg.purged:
    - pkgs:
      - stubby
      - dnscrypt-proxy

dot-extract:
  archive.extracted:
    - name: /opt/dnscrypt-proxy-{{ pillar.dns_dot.version }}
    - source: https://github.com/DNSCrypt/dnscrypt-proxy/releases/download/{{ pillar.dns_dot.version }}/dnscrypt-proxy-linux_x86_64-{{ pillar.dns_dot.version }}.tar.gz
    - skip_verify: True
    - enforce_toplevel: True
    - clean: True

/etc/dnscrypt-proxy/dnscrypt-proxy.toml:
  file.managed:
    - makedirs: True
    - template: jinja
    - source: salt://files/dns-dot/dnscrypt-proxy.toml

/usr/lib/systemd/system/dnscrypt-proxy.socket:
  file.absent: []

/usr/lib/systemd/system/dnscrypt-proxy.service:
  file.managed:
    - contents: |
        # /usr/lib/systemd/system/dnscrypt-proxy.service
        # Version with removed dnscrypt-proxy.socket deps
        [Unit]
        Description=DNSCrypt client proxy
        Documentation=https://github.com/DNSCrypt/dnscrypt-proxy/wiki
        After=network.target
        Before=nss-lookup.target
        Wants=nss-lookup.target

        [Install]
        WantedBy=multi-user.target

        [Service]
        NonBlocking=true
        ExecStart=/opt/dnscrypt-proxy-{{ pillar.dns_dot.version }}/linux-x86_64/dnscrypt-proxy -config /etc/dnscrypt-proxy/dnscrypt-proxy.toml
        ProtectHome=true
        ProtectKernelModules=true
        ProtectKernelTunables=true
        ProtectControlGroups=true
        MemoryDenyWriteExecute=true

        User=root
        CacheDirectory=dnscrypt-proxy
        LogsDirectory=dnscrypt-proxy
        RuntimeDirectory=dnscrypt-proxy

dnscrypt-proxy.service:
  service.running:
    - enable: True
    - watch:
      - file: /usr/lib/systemd/system/dnscrypt-proxy.*
      - file: /etc/dnscrypt-proxy/*
