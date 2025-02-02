vector-repository:
  pkgrepo.managed:
    - name: deb https://apt.vector.dev/ stable vector-0
    - file: /etc/apt/sources.list.d/vector.list
    - key_url: https://keys.datadoghq.com/DATADOG_APT_KEY_CURRENT.public
    - clean_file: True

vector-pkg:
  pkg.installed:
    - pkgs:
      - vector
    - refresh: True
    - require:
      - pkgrepo: vector-repository

/etc/vector/vector.yaml:
  file.managed:
    - makedirs: True
    - contents: |
        sources:
          syslog:
            type: syslog
            address: 0.0.0.0:514
            mode: udp
        sinks:
          print:
            type: "console"
            inputs:
              - syslog
            encoding:
              codec: "json"
          vlogs:
            type: elasticsearch
            inputs:
              - syslog
            endpoints:
              - {{ pillar.vector.endpoint }}
            api_version: v8
            compression: gzip
            healthcheck:
              enabled: false
            query:
              _msg_field: message
              _time_field: timestamp
              _stream_fields: host,container_name

# Main service
vector.service:
  service.running:
    - enable: True
    - watch:
      # - file: /etc/systemd/system/vector.service
      - file: /etc/vector/*
