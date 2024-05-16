roles:
  - salt-master

packages:
  - salt-master

packages_pip3:
  - salt-ssh

salt:
  roster_hosts:
    # DMZ
    home.pws: {}
    web-vm.pws: {}
    bank.pws: {}
    nexum.pws: {}
    # Julia
    pve.j.pws: {}
    home.j.pws: {}
    vpn.j.pws: {}
    # External
    eu.vds.pws:
      port: 8144
    ru.vds.pws:
      port: 8144
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
    log_level: info
    log_file: /var/log/salt/master
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
