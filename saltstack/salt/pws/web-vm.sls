system_packages:
  pkg.installed:
    - pkgs:
      - docker.io
      - docker-compose

system_proxy_conf:
  file.managed:
    - name: /etc/nginx/conf.d/proxy.conf
    - source: salt://files/pws-web-vm/proxy.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 644

# WikiMedia

wiki_rootdir:
  file.directory:
    - name:  /opt/wiki
    - makedirs: True
    - user:  root
    - group:  root
    - mode:  755

wiki_dir_images:
  file.directory:
    - name:  /opt/wiki/images
    - user:  root
    - group:  root
    - mode:  777

wiki_compose:
  file.managed:
    - name: /opt/wiki/docker-compose.yml
    - source: salt://files/pws-web-vm/wiki/docker-compose.yml
    - user: root
    - group: root
    - mode: 644

compose-wiki.service:
  file.managed:
    - name: /etc/systemd/system/compose-wiki.service
    - source: salt://files/docker-compose/systemd.service
    - template: jinja
    - user: root
    - group: root
    - context: 
      compose_path: /opt/wiki/
  service.running:
    - enable: True
    - watch:
      - file: /opt/wiki/docker-compose.yml

# Owncloud

