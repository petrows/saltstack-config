{% macro service(service_id, args={}) %}
{{ service_id }}-compose:
  file.recurse:
    - name: /opt/{{ service_id }}
    - source: salt://files/{{ service_id }}/compose
    - template: jinja
    - makedirs: True
{{ service_id }}-service:
  file.managed:
    - name: /etc/systemd/system/{{ service_id }}.service
    - source: salt://files/docker-compose/systemd.service
    - template: jinja
    - context:
      compose_path: /opt/{{ service_id }}/
  cmd.run:
    - name: docker-compose build
    - cwd: /opt/{{ service_id }}
    - onchanges:
      - file: {{ service_id }}-compose
  service.running:
    - name: {{ service_id }}.service
    - enable: True
    - watch:
      - file: /etc/systemd/system/{{ service_id }}.service
      - file: {{ service_id }}-compose
{% endmacro %}
