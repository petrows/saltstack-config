# SLS to install and configure check_mk

{% if pillar.check_mk_agent.install %}
install_check_mk:
  pkg.installed:
    - sources:
      - check-mk-agent: {{ pillar.check_mk_agent.base }}{{ pillar.check_mk_agent.filename }}
{% if pillar.check_mk_agent.ssh %}
check_mk_no_agent_port:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: DROP
    - protocol: tcp
    - dport: 6556
    - save: False
{% endif %}
{% endif %}

# Install plugins?
{% for plugin_id in salt['pillar.get']('check_mk_plugins', []) %}
# Remove .py, as it will have system interpreter usage
{% set plugin_fname = plugin_id | replace(".py", "") %}
check_mk_plugin_{{plugin_id}}:
  file.managed:
    - name: /usr/lib/check_mk_agent/plugins/{{plugin_fname}}
    - source: salt://files/check-mk/plugins/{{plugin_id}}
    - makedirs: True
    - mode: 755
{% endfor %}

# Install local checks?
{% for plugin_id in salt['pillar.get']('check_mk_local', []) %}
check_mk_plugin_{{plugin_id}}:
  file.managed:
    - name: /usr/lib/check_mk_agent/local/{{plugin_id}}
    - source: salt://files/check-mk/local/{{plugin_id}}
    - makedirs: True
    - mode: 755
{% endfor %}

# Configs
{% if 'nginx_status.py' in salt['pillar.get']('check_mk_plugins', []) %}
check_mk_plugin_nginx_status_cfg:
  file.managed:
    - name: /etc/check_mk/nginx_status.cfg
    - source: salt://files/check-mk/configs/nginx_status.cfg
    - makedirs: True
    - mode: 755
{% endif %}

{% if 'mk_logwatch.py' in salt['pillar.get']('check_mk_plugins', []) %}
check_mk_plugin_logwatch_cfg:
  file.managed:
    - name: /etc/check_mk/logwatch.cfg
    - source: salt://files/check-mk/configs/logwatch.cfg
    - makedirs: True
    - mode: 755
{% endif %}

{% if 'mk_docker.py' in salt['pillar.get']('check_mk_plugins', []) %}
check_mk_plugin_docker_cfg:
  file.managed:
    - name: /etc/check_mk/docker.cfg
    - source: salt://files/check-mk/configs/docker.cfg
    - makedirs: True
    - mode: 755
{% endif %}

{% if 'reolink_hub_stats' in salt['pillar.get']('check_mk_local', []) %}
check_mk_plugin_docker_cfg:
  file.managed:
    - name: /etc/check_mk/reolink_hub_stats.yaml
    - source: salt://files/check-mk/configs/reolink_hub_stats.yaml
    - template: jinja
    - makedirs: True
    - mode: 755
{% endif %}

# Special plugins
{% if salt['pillar.get']('check_mk_config:check_mk_awg', {}) %}
/etc/check_mk/awg.json:
  file.managed:
    - dataset_pillar: 'check_mk_config:check_mk_awg'
    - serializer: json
    - makedirs: True
    - mode: 755
{% endif %}
