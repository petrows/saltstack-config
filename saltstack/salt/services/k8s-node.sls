
k8s-banned-pkg:
  pkg.purged:
    - pkgs:
      - apparmor
      - systemd-resolved

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

# DNS config: we should ignore systemd-resolved and use direct request,
# as stub is not working correctly with k8s / containers
/etc/resolv.conf:
  file.managed:
    - contents: |
        # Direct DNS for k8s
        nameserver {{ pillar.network.dns }}

# Enforce to use local resolv.conf
/etc/default/kubelet:
  file.managed:
    - contents: |
        # Direct DNS for k8s
        KUBELET_EXTRA_ARGS="--resolv-conf=/etc/resolv.conf"

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
      - kubelet
      - containerd
      - nfs-common
    - refresh: True
    - require:
      - file: /etc/apt/sources.list.d/k8s.sources

k8s-pkg-node-hold:
  cmd.wait:
    - name: apt-mark hold kubelet
    - cwd: /
    - watch:
      - pkg: k8s-pkg-node

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
      - file: /etc/default/kubelet
      - file: /etc/resolv.conf
