# SLS to install and configure check_mk

{% if pillar.check_mk.url %}
install_check_mk:
  pkg.installed:
    - sources:
      - check-mk-agent: {{ pillar.check_mk.url }}
install_check_mk_deps:
  pkg.installed:
    - pkgs:
      - python2.7
{% endif %}

# Install plugins?
{% for plugin_id in salt.pillar.get('check_mk_plugins', []) %}
check_mk_plugin_{{plugin_id}}:
  file.managed:
    - name: /usr/lib/check_mk_agent/plugins/{{plugin_id}}
    - source: salt://files/check-mk/plugins/{{plugin_id}}
    - makedirs: True
    - mode: 755
{% endfor %}

# Configs
{% if 'nginx_status' in salt.pillar.get('check_mk_plugins', []) %}
check_mk_plugin_nginx_status_cfg:
  file.managed:
    - name: /etc/check_mk/nginx_status.cfg
    - source: salt://files/check-mk/configs/nginx_status.cfg
    - makedirs: True
    - mode: 755
{% endif %}

{% if 'mk_logwatch' in salt.pillar.get('check_mk_plugins', []) %}
check_mk_plugin_logwatch_cfg:
  file.managed:
    - name: /etc/check_mk/logwatch.cfg
    - source: salt://files/check-mk/configs/logwatch.cfg
    - makedirs: True
    - mode: 755
{% endif %}

{% if 'mk_docker.py' in salt.pillar.get('check_mk_plugins', []) %}
check_mk_plugin_docker_cfg:
  file.managed:
    - name: /etc/check_mk/docker.cfg
    - source: salt://files/check-mk/configs/docker.cfg
    - makedirs: True
    - mode: 755
{% set pip2_location = salt['cmd.shell']('which pip2') %}
docker-monitoring-pip-pkgs:
  pip.installed:
    - names:
      - docker
    - bin_env: {{ pip2_location }}
{% endif %}
