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
          docker compose down --rmi all || true
        fi
        if [[ -f cmd-down.sh ]]; then
           bash cmd-down.sh
        fi
    - cwd: /opt/{{ service_id }}
    - prereq:
      - file: {{ service_id }}-compose
    - require:
      - pkg: docker-pkg
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

# Compose script
/opt/{{ service_id }}/{{ service_id }}:
  file.managed:
    - contents: |
        #!/bin/bash
        set -xe
        if [[ -f cmd-start.sh ]]; then
          bash cmd-start.sh
        fi
        docker compose up -d
    - mode: 755
    - require:
      - file: {{ service_id }}-compose

# Systemd service
{{ service_id }}-service:
  file.managed:
    - name: /etc/systemd/system/{{ service_id }}.service
    - contents: |
        [Unit]
        Description=Docker-Compose Service for /opt/{{ service_id }}/
        Requires=docker.service
        BindsTo=docker.service
        OnFailure=status-email@%n.service
        [Service]
        Type=oneshot
        RemainAfterExit=yes
        WorkingDirectory=/opt/{{ service_id }}/
        ExecStart=/opt/{{ service_id }}/{{ service_id }}
        ExecStop=/usr/bin/docker compose down
        TimeoutStartSec=0
        [Install]
        WantedBy=docker.service
        WantedBy=multi-user.target
    - require:
      - pkg: docker-pkg

  # Build image (if needed)
  cmd.run:
    - shell: /bin/bash
    - name: |
        docker compose build
        if [[ -f cmd-build.sh ]]; then
           bash cmd-build.sh
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
