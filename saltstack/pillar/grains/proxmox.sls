roles:
  - proxmox

# Do not set hostname as 127.0.0.1!
# This will BREAK hypervisor!
network:
  # Add hostname as 127.0.0.1?
  hostname_local: False

ssh:
  # Allow PW login, as keys may fail!
  # Root authorized_keys is symlink to pve virtual folder,
  # it will fail if hypervisor is unable to start!
  allow_pw: True
