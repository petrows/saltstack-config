# Deploy salt-master service

/etc/salt/master:
  file.serialize:
    formatter: yaml
    dataset_pillar: salt.master

