# Victoria metrics cli
vmagent-installer:
  archive.extracted:
    - name: /opt/vmutils-{{ pillar.vmagent.version }}/
    - source: https://github.com/VictoriaMetrics/VictoriaMetrics/releases/download/v{{ pillar.vmagent.version }}/vmutils-linux-amd64-v{{ pillar.vmagent.version }}.tar.gz
    - skip_verify: True
    - enforce_toplevel: False

{% set vmagent_utils = ['vmagent'] %}

{% for ut in vmagent_utils %}
/usr/local/bin/{{ ut }}:
  file.symlink:
    - target: /opt/vmutils-{{ pillar.vmagent.version }}/{{ ut }}-prod
    - force: True
    - require:
      - archive: vmagent-installer
{% endfor %}

/etc/prometheus/vmagent.yaml:
  file.managed:
    - makedirs: True
    - contents: |
        global:
          scrape_interval: 15s
        scrape_configs:
          - job_name: node-exporter
            static_configs:
            {% for node in pillar.vmagent.node_exporters %}
            - targets: ['{{ node }}:9100']
            {% endfor %}
            metric_relabel_configs:
            - source_labels: [instance]
              regex: (.*):(9100)
              target_label: instance
              replacement: ${1}

{% if pillar.vmagent.enable %}
# Local buffer to collect data
# https://docs.victoriametrics.com/vmagent/#disabling-on-disk-persistence
/srv/vmagent-data/cache:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 755
    - file_mode: 644
    - makedirs: True
# Main service
vmagent.service:
  file.managed:
    - name: /etc/systemd/system/vmagent.service
    - contents: |
        [Unit]
        Description=VictoriaMetrics Agent
        After=network.target
        OnFailure=status-email@%n.service
        [Service]
        User=root
        Group=root
        WorkingDirectory=/etc/prometheus
        ExecStart=/usr/local/bin/vmagent -promscrape.config=/etc/prometheus/vmagent.yaml {% if pillar.vmagent.endpoint %} -remoteWrite.url={{ pillar.vmagent.endpoint }} -remoteWrite.tmpDataPath=/srv/vmagent-data/cache{% endif %}
        [Install]
        WantedBy=multi-user.target
  service.running:
    - enable: True
    - watch:
      - file: /etc/systemd/system/vmagent.service
      - file: /etc/prometheus/*
{% else %}
/etc/systemd/system/vmagent.service:
  file.absent: []
{% endif %}
