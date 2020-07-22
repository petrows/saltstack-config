# Install docker repos
docker_repository:
  pkgrepo.managed:
    - name: deb [arch={{ grains.osarch }}] https://download.docker.com/linux/{{ grains.os|lower }} {{ grains['oscodename'] }} stable
    - file: /etc/apt/sources.list.d/docker.list
    - keyid: 7EA0A9C3F273FCD8
    - keyserver: hkp://p80.pool.sks-keyservers.net:80

docker_pkg:
  pkg.installed:
    - pkgs:
      - docker-ce
      - docker-ce-cli
      - containerd.io
    - refresh: True
    - require:
      - pkgrepo: docker_repository

docker-compose_pkg:
  pkg.installed:
    - pkgs:
      - docker-compose
    - require:
      - pkg: docker_pkg
