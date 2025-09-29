roles:
  - proxmox

# Disable swap for pve (required by k8s)
# https://kevingoos.medium.com/kubernetes-inside-proxmox-lxc-cce5c9927942
swap_size_mb: 0
sysctl:
  vm.swappiness: 0

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

# AWG requires to setup deb-src!
apt:
  use_src: True

firewall:
  # Redirect local ports from 8006 to 443 for Proxmox web GUI access
  rules_filter_input:
    pve-https-input: tcp dport { 443, 8006 } counter accept
