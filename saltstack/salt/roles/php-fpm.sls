php-pm-repo:
  pkgrepo.managed:
    - humanname: PHP repository
    - name: deb https://packages.sury.org/php/ {{ grains.lsb_distrib_codename }} main
    - file: /etc/apt/sources.list.d/php.list
    - key_url: https://packages.sury.org/php/apt.gpg

{% set php_pkg = ['fpm','mysql','gd','mbstring','xml','curl','imagick','zip','intl','geoip'] %}

php-fpm-pkg:
  pkg.latest:
    - pkgs:
    {%- for pkg in php_pkg %}
      - php{{ pillar.php.version }}-{{ pkg }}
    {%- endfor %}
    - require:
      - pkgrepo: php-pm-repo

# Pool root
php-fpm-conf:
  file.managed:
    - name: /etc/php/{{ pillar.php.version }}/fpm/php-fpm.conf
    - source: salt://files/php/php-fpm.conf
    - template: jinja
    - require:
      - pkg: php-fpm-pkg

# Config pool for websites
php-fpm-pool-conf:
  file.managed:
    - name: /etc/php/{{ pillar.php.version }}/fpm/pool.d/{{ pillar.php.user }}.conf
    - contents: |
        [{{ pillar.php.user }}]
        user = {{ pillar.php.user }}
        group = {{ pillar.php.user }}
        listen = /var/run/php/{{ pillar.php.user }}-{{ pillar.php.version }}-fpm.sock
        listen.owner = {{ pillar.php.user_sock }}
        listen.group = {{ pillar.php.user_sock }}
        pm = dynamic
        pm.max_children = 5
        pm.start_servers = 2
        pm.min_spare_servers = 1
        pm.max_spare_servers = 3
        php_admin_value[session.save_path] = /tmp/php-fpm
    - require:
      - pkg: php-fpm-pkg

php-fpm-tmp:
  file.directory:
    - name: "/tmp/php-fpm"
    - user: {{ pillar.php.user }}
    - group: {{ pillar.php.user }}
    - makedirs: True

# Hosts config
{%- for conf_id, conf in (salt['pillar.get']('proxy_vhosts', {})).items() if conf.type == 'php' %}
php-fpm-{{ conf_id }}-web:
  file.directory:
    - name: "{{ conf.root }}/web"
    - user: {{ pillar.php.user }}
    - group: {{ pillar.php.user }}
    - makedirs: True
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
    - require:
      - pkg: php-fpm-pkg

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
      - file: /etc/php/{{ pillar.php.version }}/*
      - pkg: php-fpm-pkg
