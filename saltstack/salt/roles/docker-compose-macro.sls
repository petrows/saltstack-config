{% macro service(service_id, args={}) %}
# This macro defines standart service wrapper, running in docker + systemd

{% set compose_file = args.compose_file|default('salt://files/'+service_id+'/compose') %}

# Working directory - required for all
{{ service_id }}-workdir:
  file.directory:
    - name: /opt/{{ service_id }}
    - makedirs: True
    - mode: 700

# Cleanup old image and call cleanup script (if any)
{{ service_id }}-cleanup:
  cmd.run:
    - shell: /bin/bash
    - name: |
        if [[ -f docker-compose.yml ]]; then
          docker-compose down --rmi all || true
        fi
        if [[ -x cmd-down.sh ]]; then
           ./cmd-down.sh
        fi
    - cwd: /opt/{{ service_id }}
    - prereq:
      - file: {{ service_id }}-compose
    - require:
      - file: docker-compose-bin
      - file: {{ service_id }}-workdir

# Compose data
{{ service_id }}-compose:
  file.recurse:
    - name: /opt/{{ service_id }}
    - source: {{ compose_file }}
    - template: jinja
    - makedirs: True
    - context:
        service_id: {{ service_id }}
        args: {{ args|yaml }}

# Systemd service
{{ service_id }}-service:
  file.managed:
    - name: /etc/systemd/system/{{ service_id }}.service
    - source: salt://files/docker-compose/systemd.service
    - template: jinja
    - context:
      compose_path: /opt/{{ service_id }}/
    - require:
      - file: docker-compose-bin
  # Build image (if needed)
  cmd.run:
    - shell: /bin/bash
    - name: |
        docker-compose build
        if [[ -x cmd-build.sh ]]; then
           ./cmd-build.sh
        fi
    - cwd: /opt/{{ service_id }}
    - onchanges:
      - file: {{ service_id }}-compose
  # (re)start new systemd service (if needed)
  service.running:
    - name: {{ service_id }}.service
    - enable: True
    - watch:
      - file: /etc/systemd/system/{{ service_id }}.service
      - file: {{ service_id }}-compose
{% endmacro %}
