php-fpm-pkg:
  pkg.installed:
    - pkgs:
      - 'php-fpm'

# Common NGINX php config
php-fpm-nginx-conf:
  file.managed:
    - name: /etc/nginx/php.conf
    - source: salt://files/nginx/php.conf
    - template: jinja
    - makedirs: True
    - required:
      pkg: php-fpm-pkg
