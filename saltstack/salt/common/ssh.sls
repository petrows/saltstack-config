
/etc/ssh/sshd_config:
  file.managed:
    - source: salt://files/sshd_config
    - template: jinja

{% if grains.os == 'Ubuntu' and grains.osmajorrelease >= 23 %}
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
        {% for host_id,host in pillar.ssh.hosts_config.items() %}
        # {{ host_id }}
        Host {{ host.host }}
          {%- for conf_id,conf in host.config.items() %}
          {{ conf_id }} {{ conf }}
          {%- endfor %}
        {% endfor %}
        {% for machine_id,machine in pillar.ssh_machines.items() %}
        Host {{ machine_id }}
          HostName {{ machine_id }}
          Port {{ machine.port | default('22') }}
        {% endfor %}
