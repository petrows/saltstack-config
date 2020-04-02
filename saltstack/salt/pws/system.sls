system_packages:
  pkg.installed:
    - pkgs:
      - docker-compose

system_proxy_conf:
  file.managed:
    - name: /etc/nginx/conf.d/proxy.conf
    - source: salt://files/pws-system/proxy.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 644

system_rootdir:
  file.directory:
    - name:  /opt/system
    - user:  root
    - group:  root
    - mode:  755

system_compose:
  file.managed:
    - name: /opt/system/docker-compose.yml
    - source: salt://files/pws-system/docker-compose.yml
    - user: root
    - group: root
    - mode: 644

system-docker-compose:
  file.managed:
    - name: /etc/systemd/system/system-docker-compose.service
    - source: salt://files/pws-system/system-docker-compose.service
    - user: root
    - group: root
  service.running:
    - enable: True
    - watch:
      - file: /opt/system/docker-compose.yml