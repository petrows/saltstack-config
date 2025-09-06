
k8s-banned-pkg:
  pkg.purged:
    - pkgs:
      - apparmor

# k8s requires no swap
umount-swap:
  mount.unmounted:
    - name: none
    - device: /swap.img
    - persist: True

/swap.img:
  file.absent: []

# k8s require ip fw
net.ipv4.ip_forward:
  sysctl.present:
    - value: 1

net.bridge.bridge-nf-call-iptables:
  sysctl.present:
    - value: 1

/etc/containerd/config.toml:
  file.managed:
    - makedirs: True
    - contents: |
        version = 2
        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
        runtime_type = "io.containerd.runc.v2"
        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
        SystemdCgroup = true
        disabled_plugins = []

k8s-pkg-node:
  pkg.installed:
    - pkgs:
      - containerd
      - nfs-common
    - refresh: True

containerd.service:
  service.running:
    - enable: True
    - watch:
      - file: /etc/containerd/*

kubelet.service:
  service.running:
    - enable: True
    - watch:
      - pkg: k8s-pkg
      # Restart k8s if firewall was changed
      # - cmd: nftables-reload-main
