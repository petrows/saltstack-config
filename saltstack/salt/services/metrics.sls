{% for dir,uid in {'victoria-metrics':1100,'grafana':472}.items() %}
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
      - service: metrics.service


{% import "roles/docker-compose-macro.sls" as compose %}
{{ compose.service('metrics') }}
