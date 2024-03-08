nginx-common-packages:
  pkg.installed:
    - pkgs:
      - certbot
      - openssl

nginx:
  pkg:
    - installed
  service.running:
    - enable: True
    - require:
      - pkg: nginx

nginx-clean-configs:
  file.absent:
    - name: /etc/nginx/sites-enabled/default

nginx-config-dummy:
  file.managed:
    - name: /etc/nginx/conf.d/empty.saltstack
    - contents: ''

nginx-ssl-dummy:
  file.managed:
    - name: /etc/ssl/certs/empty.saltstack
    - contents: ''

acme-certbot-dns:
  file.managed:
    - name: /etc/letsencrypt/acme-dns-auth.py
    - source: salt://files/nginx/acme-dns-auth.py
    - mode: 0755

/etc/letsencrypt/cli.ini:
  file.managed:
    - contents: |
        # Because we are using logrotate for greater flexibility, disable the
        # internal certbot logrotation.
        max-log-backups = 0
        {%- if grains.osfinger != 'Ubuntu-20.04' %}
        # Adjust interactive output regarding automated renewal
        preconfigured-renewal = True
        {%- endif %}
        # Reload nginx on renew
        deploy-hook = systemctl reload nginx

# Hosts config
{%- for conf_id, conf in (salt['pillar.get']('proxy_vhosts', {})).items() %}

# Conf type
{% set conf_type = conf['type']|default('proxy') %}

# Prepare SSL config
{% set ssl_type = conf['ssl']|default(None) %}
{% set ssl_cert = None %}
{% set ssl_key = None %}

{% if ssl_type == 'external' and salt['file.file_exists']('/etc/letsencrypt/live/'+conf.domain+'/fullchain.pem') %}
  {% set ssl_cert = '/etc/letsencrypt/live/'+conf.domain+'/fullchain.pem' %}
  {% set ssl_key = '/etc/letsencrypt/live/'+conf.domain+'/privkey.pem' %}
{% endif %} # / external

{% if ssl_type == 'internal' %}
{% set ssl_cert = '/etc/ssl/certs/pws-internal-'+conf.ssl_name+'.crt' %}
{% set ssl_key = '/etc/ssl/certs/pws-internal-'+conf.ssl_name+'.key' %}
# Deploy internal key
nginx-ssl-iternal-pem-{{ conf_id }}:
  file.managed:
    - name: {{ ssl_cert }}
    - contents: {{ pillar['pws_secrets']['ssl_pws_'+conf.ssl_name]['crt']|yaml }}
    - user: root
    - group: root
    - mode: 644
nginx-ssl-iternal-key-{{ conf_id }}:
  file.managed:
    - name:  {{ ssl_key }}
    - contents: {{ pillar['pws_secrets']['ssl_pws_'+conf.ssl_name]['key']|yaml }}
    - user: root
    - group: root
    - mode: 644
{% endif %} # / internal

# Fallback
{% if not ssl_cert and ssl_type %}
  {% set ssl_cert = '/etc/ssl/certs/ssl-selfsigned.crt' %}
  {% set ssl_key = '/etc/ssl/certs/ssl-selfsigned.key' %}
{% endif %}

nginx-proxy-conf-{{ conf_id }}:
  file.managed:
    - name: /etc/nginx/conf.d/{{ conf_id }}.conf
    - source: salt://files/nginx/vhost.j2
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - context:
      conf_id: {{ conf_id }}
      conf_type: {{ conf_type }}
      conf: {{ conf|yaml }}
      ssl_type: {{ ssl_type }}
      ssl_cert: {{ ssl_cert }}
      ssl_key: {{ ssl_key }}
    {% if 'php' == conf_type %}
    - require:
      - file: php-fpm-pool-conf
    {% endif %}
{% endfor %}

{% if pillar.nginx.dhparam %}
nginx-dh:
  cmd.run:
    - name: "openssl dhparam -out /etc/nginx/dhparam.pem 4096"
    - runas: root
    - creates:
      - /etc/nginx/dhparam.pem
{% endif %}

nginx-ssl-selfsigned:
  cmd.run:
    - name: "mkdir -p /etc/ssl/certs ; openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/certs/ssl-selfsigned.key -out /etc/ssl/certs/ssl-selfsigned.crt -batch"
    - runas: root
    - creates:
      - /etc/ssl/certs/ssl-selfsigned.crt
      - /etc/ssl/certs/ssl-selfsigned.key

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
      - file: /etc/nginx/*
      - file: /etc/ssl/certs/*

