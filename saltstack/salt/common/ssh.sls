
/etc/ssh/sshd_config:
  file.managed:
    - source: salt://files/sshd_config
    - template: jinja

sshd.service:
  service.running:
    - enable: True
    - watch:
      - file: /etc/ssh/*

# Local hosts config

/etc/ssh/ssh_config.d/salt.conf:
  file.managed:
    - makedirs: True
    - contents: |
        {% for machine_id,machine in pillar.ssh_machines.items() %}
        Host {{ machine_id }}
          HostName {{ machine_id }}
          Port {{ machine.port | default('22') }}
        {% endfor %}
