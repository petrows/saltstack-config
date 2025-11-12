# Install docker repos

/etc/apt/sources.list.d/docker.list:
  file.absent: []

/etc/apt/sources.list.d/docker.sources:
  file.managed:
    - contents: |
        X-Repolib-Name: Docker
        Description: Docker is a set of platform as a service products that use OS-level virtualization to deliver software in packages called containers.
          - Website: https://www.docker.com
          - Public key: https://download.docker.com/linux/{{ grains.os|lower }}/gpg
        Enabled: yes
        Types: deb
        URIs: https://download.docker.com/linux/{{ grains.os|lower }}
        Signed-By: /etc/apt/keyrings/docker.gpg
        Suites: {{ grains['oscodename'] }}
        Components: stable

docker-pkg:
  pkg.installed:
    - pkgs:
      - docker-ce
      - docker-ce-cli
      - containerd.io
    - refresh: True
    - require:
      - file: /etc/apt/sources.list.d/docker.sources

docker-config:
  file.managed:
    - name: /etc/docker/daemon.json
    - source: salt://files/docker-compose/daemon.json
    - template: jinja

docker.service:
  service.running:
    - enable: True
    - watch:
      - pkg: docker-pkg
      - file: /etc/docker/*
      # Restart Docker if firewall was changed
      - cmd: nftables-reload-main

# Add users to docker
{% for user_id in salt['pillar.get']('docker:users', []) %}
docker-user-{{user_id}}:
  group.present:
    - name: docker
    - addusers:
      - {{ user_id }}
    - require:
      - user: user_{{user_id}}_config
{% endfor %}
