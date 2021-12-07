{% for dir,uid in {'victoriametrics':1100,'grafana':472,'telegraf':1000,'vmagent':1000,'snmp_exporter':1000}.items() %}
metrics-dir-{{ dir }}:
  file.directory:
    - name: {{ pillar.metrics.data_dir }}/{{ dir }}
    - makedirs: True
    - user: {{ uid }}
    - group: {{ uid }}
    - mode:  755
{% endfor %}

{{ pillar.metrics.data_dir }}/grafana:
  file.recurse:
    - source: salt://files/metrics/grafana
    - makedirs: True
    - template: jinja
    - user: 472
    - group: 472
    - watch_in:
      - service: metrics-compose

{{ pillar.metrics.data_dir }}/telegraf/telegraf.conf:
  file.managed:
    - source: salt://files/metrics/telegraf.conf
    - template: jinja
    - watch_in:
      - service: metrics-compose

{{ pillar.metrics.data_dir }}/vmagent/vmagent.yml:
  file.managed:
    - source: salt://files/metrics/vmagent.yml
    - template: jinja
    - watch_in:
      - service: metrics-compose

{{ pillar.metrics.data_dir }}/snmp_exporter/snmp.yml:
  file.managed:
    - source: salt://files/metrics/snmp.yml
    - template: jinja
    - watch_in:
      - service: metrics-compose

{% import "roles/docker-compose-macro.sls" as compose %}
{{ compose.service('metrics') }}
