node_exporter-pkg:
  pkg.installed:
    - pkgs:
      - prometheus-node-exporter

/var/lib/node_exporter/metrics:
  file.directory:
    - makedirs: True
    - owner: root
    - group: root
    - mode: '755'

/etc/default/prometheus-node-exporter:
  file.managed:
    - makedirs: True
    - contents: |
        # Managed by Saltstack
        # Default options for prometheus-node-exporter
        # See /usr/bin/prometheus-node-exporter --help for more details
        ARGS="--collector.textfile.directory=/var/lib/node_exporter/metrics"

prometheus-node-exporter.service:
  service.running:
    - enable: True
    - watch:
      - file: /etc/default/prometheus-node-exporter
