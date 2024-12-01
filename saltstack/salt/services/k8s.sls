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
