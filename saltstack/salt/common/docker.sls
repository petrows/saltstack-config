# Install Debian docker
{% if grains['os'] == 'Debian' %}
docker_repository:
  pkgrepo.managed:
    - name: deb [arch=amd64] https://download.docker.com/linux/debian {{ grains['oscodename'] }} stable
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
{% else %}
docker_pkg:
  pkg.installed:
    - pkgs:
      - docker.io
{% endif %}

docker-compose_pkg:
  pkg.installed:
    - pkgs:
      - docker-compose
    - require:
      - pkg: docker_pkg
