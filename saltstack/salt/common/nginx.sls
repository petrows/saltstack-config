common_packages:
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
    - cwd: root
    - runas: root
    - creates:
      - /etc/nginx/dhparam.pem

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

