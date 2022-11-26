# Install docker repos
docker-repository:
  pkgrepo.managed:
    - name: deb [arch={{ grains.osarch }}] https://download.docker.com/linux/{{ grains.os|lower }} {{ grains['oscodename'] }} stable
    - key_url: https://download.docker.com/linux/{{ grains.os|lower }}/gpg

docker-pkg:
  pkg.installed:
    - pkgs:
      - docker-ce
      - docker-ce-cli
      - containerd.io
    - refresh: True
    - require:
      - pkgrepo: docker-repository

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

# We will remove (potentially outdated) package and install it from official source
docker-compose-pkg-clean:
  pkg.purged:
    - pkgs:
      - docker-compose

docker-compose-bin:
  file.managed:
    - name: /usr/local/bin/docker-compose
    - source: {{ pillar.docker_compose.url }}
    - source_hash: {{ pillar.docker_compose.sha256 }}
    - mode: 755
    - user: root
    - group: root

docker-compose-bin-symlink:
  file.symlink:
    - name: /usr/bin/docker-compose
    - target: /usr/local/bin/docker-compose

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
