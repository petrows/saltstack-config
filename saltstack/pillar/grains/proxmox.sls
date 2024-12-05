roles:
  - proxmox

# Disable swap for pve (required by k8s)
# https://kevingoos.medium.com/kubernetes-inside-proxmox-lxc-cce5c9927942
swap_size_mb: 0
sysctl:
  vm.swappiness: 0
  net.bridge.bridge-nf-call-iptables: 1
  net.bridge.bridge-nf-call-ip6tables: 1
  net.ipv4.ip_forward: 1

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

# Load some modules, required for k8s
kernel-modules:
  overlay: True
  br_netfilter: True
  ip_vs: True
  nf_nat: True
  xt_conntrack: True
