
/etc/ssh/sshd_config:
  file.managed:
    - source: salt://files/sshd_config
    - template: jinja

{% if grains.osfinger == 'Ubuntu-22.10' %}
ssh.service:
{% else %}
sshd.service:
{% endif %}
  service.running:
    - enable: True
    - watch:
      - file: /etc/ssh/*

# Local config

/etc/ssh/ssh_config:
  file.managed:
    - makedirs: True
    - contents: |
        # This file is managed by SALT
        Include /etc/ssh/ssh_config.d/*.conf
        Host *
            SendEnv LANG LC_*
            HashKnownHosts yes
            GSSAPIAuthentication yes


# Local hosts config

/etc/ssh/ssh_config.d/salt.conf:
  file.managed:
    - makedirs: True
    - contents: |
        # This file is managed by SALT
        {% for machine_id,machine in pillar.ssh_machines.items() %}
        Host {{ machine_id }}
          HostName {{ machine_id }}
          Port {{ machine.port | default('22') }}
        {% endfor %}
