{% import_yaml 'static.yaml' as static %}
{% import_yaml 'network.yaml' as static_network %}

roles:
  - php-docker
  - mounts

# Static network config
network:
  netplan:
    network:
      version: 2
      renderer: networkd
      ethernets:
        eth-lan:
          match:
            macaddress: ea:5f:a5:bd:84:81
          set-name: eth-lan
          # ipv4: auto
          dhcp4: yes
          # ipv6: static
          addresses:
            - {{ static_network.hosts.pws_web_vm.lan.ipv6.addr }}/{{ static_network.hosts.pws_web_vm.lan.ipv6.size }}
          routes:
            - to: "::/0"
              via: {{ static_network.networks.pws_dmz.ipv6.gw }}
              on-link: true

# Force generate new dhparm keys for Nginx (required for external servers)
nginx:
  dhparam: True

# Web sites
proxy_vhosts:
  petro-wp-www:
    type: redirect
    domain: www.petro.ws
    ssl: external
    redirect_target: 'https://petro.ws/'
    enable_robots: True
  petro-wp:
    type: php-docker
    domain: petro.ws
    ssl: external
    enable_robots: True
    root: /srv/petro-wp
    port: {{ static.proxy_ports.petro_wp_http }}
    php:
      user: www-data
      version: 7.4
      cron:
        wp-cron:
          calendar: '*-*-* *:*:00'
          cmd: php wp-cron.php
      cfg:
        post_max_size: 1G
        upload_max_filesize: 1G
        memory_limit: 1G
      db:
        type: mariadb
        image: mariadb:10.7
        dbname: petro_wp
        credentials: petrows_db
  # petro-trs:
  #   type: php-docker
  #   root: /srv/petro-trs
  #   port: {{ static.proxy_ports.petro_trs_http }}
  #   domain: trs.petro.ws
  #   ssl: external
  #   php:
  #     user: www-data
  #     version: 7.4
  #     cron:
  #       update:
  #         calendar: '*-*-* *:00/5:00'
  #         cmd: php update.php --feeds
  #     db:
  #       type: mariadb
  #       image: mariadb:10.7
  #       dbname: petro_trs
  #       credentials: petrows_db
  petro-tools:
    type: php-docker
    root: /srv/petro-tools
    port: {{ static.proxy_ports.petro_tools_http }}
    domain: tools.petro.ws
    ssl: external
    enable_robots: True
    php:
      user: www-data
      version: 7.4
      rewrite_rule: /index.php?url=$uri&$args

  # Proxy record to external apps
  firefly:
    port: {{ static.proxy_ports.firefly_http }}
    host: 10.80.1.5
    domain: bank.petro.ws
    ssl: external
    enable_robots: False
  # Yandex-alice endpoint
  yandex-home:
    port: 4001
    host: 10.80.6.2
    proto: https
    domain: y2m.eh.petro.ws
    ssl: external
    enable_robots: False
  # Sb0y endpoint
  sb0y-proxy:
    port: 4343
    host: 10.80.1.7
    domain: eu-ptr.bagrintsev.me
    ssl: external
    enable_robots: False
