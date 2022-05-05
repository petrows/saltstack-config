roles:
  - salt-master

packages_pip3:
  - salt-ssh

salt:
  roster_hosts:
    # DMZ
    web-vm.pws: {}
    build-linux.pws: {}
    nexum.pws: {}
    # External
    eu.vds.pws:
      port: 8144
    ru.vds.pws:
      port: 8144
    # rpi.office.pws: {}
  master:
    file_roots:
      base:
        - /srv/salt-config/saltstack/salt
        - /srv/salt-config/secrets/salt
    pillar_roots:
      base:
        - /srv/salt-config/saltstack/pillar
        - /srv/salt-config/secrets/pillar
    pillar_merge_lists: True
    gather_job_timeout: 60
    # Disable display of non-chaged services by default
    # Can be overriden by --state-verbose=true
    state_verbose: False
    # Salt-ssh options
    roster_defaults:
      minion_opts:
        pillar_merge_lists: True
      user: salt
      sudo: True
      priv: /etc/salt/salt-ssh/id_ed25519
      tty: True
