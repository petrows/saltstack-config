roles:
  - salt-master

salt:
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
