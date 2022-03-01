# Deploy salt-master service

/etc/salt/master:
  file.serialize:
    - formatter: yaml
    - dataset_pillar: salt:master

/etc/salt/roster:
  file.serialize:
    - formatter: yaml
    - dataset_pillar: salt:roster_hosts

/etc/salt/salt-ssh/id_ed25519:
  file.managed:
    - contents_pillar: pws_secrets:ssh_salt_private:private
    - makedirs: True
    - mode: 600

/etc/salt/salt-ssh/id_ed25519.pub:
  file.managed:
    - contents_pillar: pws_secrets:ssh_salt_private:public
    - makedirs: True
    - mode: 600

# Install cached copy of check-mk agent
/srv/salt-config/saltstack/salt/packages/{{ pillar.check_mk_agent.filename }}:
  file.managed:
    - source: {{ pillar.check_mk_agent.base }}{{ pillar.check_mk_agent.filename }}
    - source_hash: {{ pillar.check_mk_agent.checksum }}
    - makedirs: True

# Salt-sync service

/usr/sbin/saltstack-sync:
  file.managed:
    - mode: 755
    - contents: |
        #!/bin/bash -xe
        cd /srv/salt-config/
        git pull
        cd secrets
        git reset --hard HEAD
        cd ..
        timeout 1h salt '*' state.apply
        timeout 1h salt-ssh --hard-crash '*' state.apply

saltstack-sync.service:
  file.managed:
    - name: /etc/systemd/system/saltstack-sync.service
    - contents: |
        [Unit]
        Description=Saltstack sync
        After=network.target
        [Service]
        User=root
        Group=root
        WorkingDirectory=/srv/salt-config/
        ExecStart=/usr/sbin/saltstack-sync
  service.enabled:
    - enable: True

saltstack-sync.timer:
  file.managed:
    - name: /etc/systemd/system/saltstack-sync.timer
    - contents: |
        [Unit]
        Description=Saltstack sync timer
        [Timer]
        OnCalendar=*-*-* 4:00:00
        Unit=saltstack-sync.service
        [Install]
        WantedBy=timers.target
  service.running:
    - enable: True
