roles:
  - salt-master

packages_pip3:
  - salt-ssh

salt:
  roster_hosts:
    # DMZ
    web-vm.pws: {}
    # External
    eu.petro.ws: {}
  master:
    file_roots:
      base:
        - /srv/salt-config/saltstack/salt
    pillar_roots:
      base:
        - /srv/salt-config/saltstack/pillar
    pillar_merge_lists: True
    gather_job_timeout: 60
    # Disable display of non-chaged services by default
    # Can be overriden by --state-verbose=true
    state_verbose: False
    # Salt-ssh options
    roster_defaults:
      user: salt
      sudo: True
      priv: /etc/salt/salt-ssh/id_ed25519
      tty: True
