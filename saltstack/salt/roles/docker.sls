# Install docker repos
docker-repository:
  pkgrepo.managed:
    - name: deb [arch={{ grains.osarch }}] https://download.docker.com/linux/{{ grains.os|lower }} {{ grains['oscodename'] }} stable
    - file: /etc/apt/sources.list.d/docker.list
    - key_url: https://download.docker.com/linux/{{ grains.os|lower }}/gpg
    - clean_file: True

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

{% set compose_name = 'docker-compose-' + (grains.kernel|lower) + '-' + grains.cpuarch %}
{% set compose_url = 'https://github.com/docker/compose/releases/download/v' + pillar.docker_compose.version + '/' + compose_name %}
{% set compose_url_hash = compose_url + '.sha256' %}

docker-compose-hash:
  file.managed:
    - name: /var/cache/salt/{{ compose_name }}.sha256
    - source: {{ compose_url_hash }}
    - skip_verify: True
    - makedirs: True

docker-compose-bin:
  file.managed:
    - name: /usr/local/bin/docker-compose
    - source: {{ compose_url }}
    - source_hash: /var/cache/salt/{{ compose_name }}.sha256
    - mode: 755
    - user: root
    - group: root
    - watch:
      - file: docker-compose-hash

docker-compose-bin-local-symlink:
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
