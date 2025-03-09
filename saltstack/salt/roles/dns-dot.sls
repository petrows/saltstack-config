# Configgure DNS-Over-TLS (DoT)

dot-pkg:
  pkg.installed:
    - pkgs:
      - stubby

/etc/stubby/stubby.yml:
  file.managed:
    - contents: |
        resolution_type: GETDNS_RESOLUTION_STUB
        dns_transport_list:
          - GETDNS_TRANSPORT_TLS
        tls_authentication: GETDNS_AUTHENTICATION_REQUIRED
        tls_query_padding_blocksize: 256
        edns_client_subnet_private : 1
        idle_timeout: 10000
        listen_addresses:
        {%- for listen in pillar.dns_dot.listen %}
          - {{ listen }}
        {%- endfor %}
        round_robin_upstreams: 1
        upstream_recursive_servers:
        {%- for upstream in pillar.dns_dot.upstream %}
          - address_data: {{ upstream.ip }}
            tls_auth_name: "{{ upstream.tls_auth_name }}"
        {%- endfor %}

stubby.service:
  service.running:
    - enable: True
    - watch:
      - file: /etc/stubby/*
