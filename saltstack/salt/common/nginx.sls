nginx-common-packages:
  pkg.installed:
    - pkgs:
      - openssl

nginx:
  pkg:
    - installed
  service.running:
    - enable: True
    - required:
      - pkg: nginx

nginx-config-dummy:
  file.managed:
    - name: /etc/nginx/conf.d/empty.saltstack
    - contents: ''

nginx-dh:
  cmd.run:
    - name: "openssl dhparam -out /etc/nginx/dhparam.pem 4096"
    - runas: root
    - creates:
      - /etc/nginx/dhparam.pem

nginx-ssl:
  cmd.run:
    - name: "openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl-selfsigned.key -out /etc/nginx/ssl-selfsigned.crt -batch"
    - runas: root
    - creates:
      - /etc/nginx/ssl-selfsigned.key

nginx-rootconf:
  file.managed:
    - name: /etc/nginx/nginx.conf
    - source: salt://files/nginx/nginx.conf
    - user: root
    - group: root
    - mode: 644

nginx-acme:
  file.managed:
    - name: /etc/nginx/acme.conf
    - source: salt://files/nginx/acme.conf
    - user: root
    - group: root
    - mode: 644

nginx-acme-root:
  file.directory:
    - name:  /var/www/letsencrypt
    - user:  root
    - group:  root
    - mode:  777

reload-nginx:
  service.running:
    - name: nginx
    - enable: True
    - reload: True
    - watch:
      - module: nginx-config-test

nginx-config-test:
  module.wait:
    - name: nginx.configtest
    - watch:
      - file: /etc/nginx/conf.d/*
      - file: /etc/nginx/nginx.conf

