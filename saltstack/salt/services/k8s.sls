# The K8S services role

k8s-repository:
  pkgrepo.managed:
    - name: deb https://pkgs.k8s.io/core:/stable:/v{{ pillar.k8s.version }}/deb/ /
    - key_url: https://pkgs.k8s.io/core:/stable:/v{{ pillar.k8s.version }}/deb/Release.key
    - file: /etc/apt/sources.list.d/k8s.list
    - clean_file: True

k8s-pkg:
  pkg.installed:
    - pkgs:
      - kubelet: '{{ pillar.k8s.version }}.*'
      - kubeadm: '{{ pillar.k8s.version }}.*'
      - kubectl: '{{ pillar.k8s.version }}.*'
      - kubectx
      - containerd
    - refresh: True
    - require:
      - pkgrepo: k8s-repository

k8s-pkg-hold:
  cmd.wait:
    - name: apt-mark hold kubelet kubeadm kubectl
    - cwd: /
    - watch:
      - pkg: k8s-pkg

# Helm
helm-repository:
  pkgrepo.managed:
    - name: deb https://baltocdn.com/helm/stable/debian/ all main
    - key_url: https://baltocdn.com/helm/signing.asc
    - file: /etc/apt/sources.list.d/helm.list
    - clean_file: True

# Krew
# To isntall for current user, run:
# /opt/krew/krew-linux_amd64 install krew
k8s-krew:
  archive.extracted:
    - name: /opt/krew/
    - source: https://github.com/kubernetes-sigs/krew/releases/download/v{{ pillar.k8s.krew.version }}/krew-linux_{{ grains.osarch }}.tar.gz
    - skip_verify: True

{% if pillar.k8s.node %}

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

{% endif %}

# {%- set default_interface = (salt['network.default_route']('inet')|first)['interface']|default('none') %}
# {%- if default_interface %}
#     {%- set default_addr = (salt['network.interface_ip'](default_interface)) %}
# {%- endif %}

# /tmp/k8s-init.yaml:
#   file.managed:
#     - contents: |
#         apiVersion: kubeadm.k8s.io/v1beta3
#         kind: InitConfiguration
#         localAPIEndpoint:
#           advertiseAddress: {{ default_addr }}
#           bindPort: 6443
#         nodeRegistration:
#           kubeletExtraArgs:
#             node-ip: {{ default_addr }}
#         ---
#         apiVersion: kubeadm.k8s.io/v1beta3
#         kind: ClusterConfiguration
#         kubernetesVersion: 1.28.8
#         controlPlaneEndpoint: "k8s-cp.pws:6443"
#         networking:
#           podSubnet: 10.99.0.0/16
