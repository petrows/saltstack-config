php-fpm-pkg:
  pkg.latest:
    - pkgs:
      - php-fpm

# Config pool
php-fpm-pool-conf:
  file.managed:
    - name: /etc/php/{{ pillar.php.version }}/fpm/pool.d/{{ pillar.php.pool_name }}.conf
    - contents: |
        [{{ pillar.php.pool_name }}]
        user = {{ pillar.php.user }}
        group = {{ pillar.php.user }}
        listen = /run/php/php{{ pillar.php.version }}-fpm.sock
        listen.owner = www-data
        listen.group = www-data
        pm = dynamic
        pm.max_children = 5
        pm.start_servers = 2
        pm.min_spare_servers = 1
        pm.max_spare_servers = 3

# Common NGINX php config
php-fpm-nginx-conf:
  file.managed:
    - name: /etc/nginx/php.conf
    - source: salt://files/nginx/php.conf
    - template: jinja
    - makedirs: True
    - require:
      - pkg: php-fpm-pkg

php{{ pillar.php.version }}-fpm.service:
  service.running:
    - enable: True
    - watch:
      - file: php-fpm-pool-conf
