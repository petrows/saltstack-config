# Install docker repos
docker-repository:
  pkgrepo.managed:
    - name: deb [arch={{ grains.osarch }}] https://download.docker.com/linux/{{ grains.os|lower }} {{ grains['oscodename'] }} stable
    - file: /etc/apt/sources.list.d/docker.list
    - keyid: 7EA0A9C3F273FCD8
    - keyserver: hkp://p80.pool.sks-keyservers.net:80

docker-pkg:
  pkg.installed:
    - pkgs:
      - docker-ce
      - docker-ce-cli
      - containerd.io
    - refresh: True
    - require:
      - pkgrepo: docker-repository

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
