# Do not auto update server from -dev scope
saltstack:
  auto_apply: False

# Do not erase Vagrant SSH keys
ssh:
  force_manage: False

# Monitoring disabled
check_mk:
  url: False
