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
        listen.owner = {{ pillar.php.user_sock }}
        listen.group = {{ pillar.php.user_sock }}
        pm = dynamic
        pm.max_children = 5
        pm.start_servers = 2
        pm.min_spare_servers = 1
        pm.max_spare_servers = 3
        chroot = {{ pillar.php.home }}

# PHP preps
php-fpm-tmp:
  file.directory:
    - name: "{{ pillar.php.home }}/tmp/php"
    - user: {{ pillar.php.user }}
    - group: {{ pillar.php.user }}
    - makedirs: True

# PHP config
php-fpm-ini:
  file.managed:
    - name: /etc/php/{{ pillar.php.version }}/fpm/php.ini
    - contents: |
        [PHP]
        error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT
        display_errors = Off
        display_startup_errors = Off
        log_errors = On
        memory_limit = 512M
        post_max_size = 512M
        upload_max_filesize = 512M
        [Session]
        session.save_handler = files
        session.save_path = "N;{{ pillar.php.home }}/tmp/php"
        session.use_only_cookies = 1
        session.cookie_httponly = 1

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
