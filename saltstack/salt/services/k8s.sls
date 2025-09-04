# The K8S services role
/etc/apt/sources.list.d/k8s.list:
  file.absent: []

/etc/apt/sources.list.d/k8s.sources:
  file.managed:
    - name: /etc/apt/sources.list.d/k8s.sources
    - contents: |
        X-Repolib-Name: Kubernetes
        Description: Kubernetes is an open-source system for automating deployment, scaling, and management of containerized applications.
          It groups containers that make up an application into logical units for easy management and discovery.
          - Website: https://kubernetes.io
          - Public key: https://pkgs.k8s.io/core:/stable:/v{{ pillar.k8s.version }}/deb/Release.key
        Enabled: yes
        Types: deb
        URIs: https://pkgs.k8s.io/core:/stable:/v{{ pillar.k8s.version }}/deb/
        Signed-By: /etc/apt/keyrings/k8s.gpg
        Suites: /

k8s-pkg:
  pkg.installed:
    - pkgs:
      - kubelet: '{{ pillar.k8s.version }}.*'
      - kubeadm: '{{ pillar.k8s.version }}.*'
      - kubectl: '{{ pillar.k8s.version }}.*'
      - kubectx
    - refresh: True
    - require:
      - file: /etc/apt/sources.list.d/k8s.sources

k8s-pkg-hold:
  cmd.wait:
    - name: apt-mark hold kubelet kubeadm kubectl
    - cwd: /
    - watch:
      - pkg: k8s-pkg

# Helm
/etc/apt/sources.list.d/helm.list:
  file.absent: []

/etc/apt/sources.list.d/helm.sources:
  file.managed:
    - name: /etc/apt/sources.list.d/helm.sources
    - contents: |
        X-Repolib-Name: Helm
        Description: Helm is a tool for managing Kubernetes charts.
          It allows you to define, install, and upgrade even the most complex Kubernetes applications.
          Helm uses a packaging format called charts.
          - Website: https://helm.sh
          - Public key: https://packages.buildkite.com/helm-linux/helm-debian/gpgkey
        Enabled: yes
        Types: deb
        URIs: https://packages.buildkite.com/helm-linux/helm-debian/any/
        Signed-By: /etc/apt/keyrings/helm.gpg
        Suites: any
        Components: main

# Krew
# To isntall for current user, run:
# /opt/krew/krew-linux_amd64 install krew
k8s-krew:
  archive.extracted:
    - name: /opt/krew/
    - source: https://github.com/kubernetes-sigs/krew/releases/download/v{{ pillar.k8s.krew.version }}/krew-linux_{{ grains.osarch }}.tar.gz
    - skip_verify: True
