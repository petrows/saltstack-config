nginx:
  pkg:
    - installed
  service.running:
    - enable: True
    - required:
      - pkg: nginx

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
