install_check_mk:
  pkg.installed:
    - sources:
      - check-mk-agent: http://cmk.system.pws/cmk/check_mk/agents/check-mk-agent_1.6.0p10-1_all.deb

# Install plugins?
{% for plugin_id in salt.pillar.get('check_mk_plugins', []) %}
check_mk_plugin_{{plugin_id}}:
  file.managed:
    - name: /usr/lib/check_mk_agent/plugins/{{plugin_id}}
    - source: salt://files/check-mk/plugins/{{plugin_id}}
    - user: root
    - group: root
    - mode: 755
{% endfor %}

# Configs
{% if 'nginx_status' in salt.pillar.get('check_mk_plugins', []) %}
check_mk_plugin_nginx_status_cfg:
  file.managed:
    - name: /etc/check_mk/nginx_status.cfg
    - source: salt://files/check-mk/configs/nginx_status.cfg
    - user: root
    - group: root
    - mode: 755
{% endif %}
