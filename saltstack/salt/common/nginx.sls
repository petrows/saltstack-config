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
    - required:
      - pkg: nginx

nginx-config-dummy:
  file.managed:
    - name: /etc/nginx/conf.d/empty.saltstack
    - contents: ''

# Hosts config
{%- for conf_id, conf in (salt['pillar.get']('proxy_vhosts', {})).items() %}

# Prepare SSL config
{% set ssl_type = conf['ssl']|default(None) %}
{% set ssl_cert = None %}
{% set ssl_key = None %}

{% if ssl_type == 'external' %}
  {% set ssl_cert = '/etc/letsencrypt/live/'+conf.domain+'/fullchain.pem' %}
  {% set ssl_key = '/etc/letsencrypt/live/'+conf.domain+'/fullchain.pem' %}
{% endif %}

{% if ssl_type == 'internal' %}
  {% set ssl_cert = '/etc/ssl/certs/pws-internal.pem' %}
  {% set ssl_key = '/etc/ssl/certs/pws-internal.key' %}
{% endif %}

# Fallback
{% if (ssl_cert and not salt['file.file_exists'](ssl_cert)) %}
  {% set ssl_cert = '/etc/nginx/ssl-selfsigned.crt' %}
  {% set ssl_key = '/etc/nginx/ssl-selfsigned.key' %}
{% endif %}

nginx-proxy-conf-{{ conf_id }}:
  file.managed:
    - name: /etc/nginx/conf.d/{{ conf_id }}.conf
    - source: salt://files/nginx/nginx-proxy.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - context:
      conf_id: {{ conf_id }}
      conf: {{ conf|yaml }}
      ssl_type: {{ ssl_type }}
      ssl_cert: {{ ssl_cert }}
      ssl_key: {{ ssl_key }}
{% endfor %}

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

