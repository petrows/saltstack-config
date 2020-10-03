# Basic config for Wordpress app running

{% import_yaml 'static.yaml' as static %}

roles:
  - docker
  - nginx
  - wiki

wordpress:
  version: 5.5.1-php7.2-fpm
  version_mysql: 10.5
  data_dir: /srv/petrows-blog-data

proxy_vhosts:
  wiki:
    domain: petrows-blog.local.pws
    port: {{ static.proxy_ports.pws_blog_http }}
    ssl: internal
    ssl_name: local
