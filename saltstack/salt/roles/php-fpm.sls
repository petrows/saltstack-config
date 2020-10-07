php-pm-repo:
  pkgrepo.managed:
    - humanname: PHP repository
    - name: deb https://packages.sury.org/php/ {{ grains.lsb_distrib_codename }} main
    - file: /etc/apt/sources.list.d/php.list
    - key_url: https://packages.sury.org/php/apt.gpg

php-fpm-pkg:
  pkg.latest:
    - pkgs:
      - php-fpm
      - php-mysql
      - php-gd
      - php-mbstring
      - php-xml
      - php-curl
      - php-imagick
      - php-zip
    - require:
      - pkgrepo: php-pm-repo

# Hosts config
{%- for conf_id, conf in (salt.pillar.get('proxy_vhosts', {})).items() if conf.type == 'php' %}
# Config pool for website
php-fpm-{{ conf_id }}-pool-conf:
  file.managed:
    - name: /etc/php/{{ pillar.php.version }}/fpm/pool.d/{{ conf_id }}.conf
    - contents: |
        [{{ conf_id }}]
        user = {{ pillar.php.user }}
        group = {{ pillar.php.user }}
        listen = /var/run/php/{{ conf_id }}-{{ pillar.php.version }}-fpm.sock
        listen.owner = {{ pillar.php.user_sock }}
        listen.group = {{ pillar.php.user_sock }}
        pm = dynamic
        pm.max_children = 5
        pm.start_servers = 2
        pm.min_spare_servers = 1
        pm.max_spare_servers = 3
        chroot = {{ conf.root }}
        php_admin_value[session.save_path] = {{ conf.root }}/tmp
    - require:
      - pkg: php-fpm-pkg

# PHP preps
php-fpm-{{ conf_id }}-web:
  file.directory:
    - name: "{{ conf.root }}/web"
    - user: {{ pillar.php.user }}
    - group: {{ pillar.php.user }}
    - makedirs: True
php-fpm-{{ conf_id }}-tmp:
  file.directory:
    - name: "{{ conf.root }}/tmp"
    - user: {{ pillar.php.user }}
    - group: {{ pillar.php.user }}
    - makedirs: True

# Chroot stuff
{%- for php_mount in ['/usr', '/bin', '/etc', '/lib', '/lib64', '/lib32', '/dev'] %}
php-fpm-{{ conf_id }}-mount-{{ php_mount }}:
  mount.mounted:
    - name: {{ conf.root }}{{ php_mount }}
    - device: {{ php_mount }}
    - opts: bind
    - fstype: none
    - mkmnt: True
    - persist: False
{% endfor %}

{% endfor %} # / vhost

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
        date.timezone = {{ pillar.timezone }}
        memory_limit = 512M
        post_max_size = 512M
        upload_max_filesize = 512M
        [Session]
        session.save_handler = files
        session.save_path = "N;{{ pillar.php.home }}/tmp/php"
        session.use_only_cookies = 1
        session.cookie_httponly = 1

# Common NGINX php config (for default system pool)
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
    - reload: True
    - watch:
      - file: php-fpm-ini
      - file: /etc/php/{{ pillar.php.version }}/fpm/pool.d/*
      - pkg: php-fpm-pkg
