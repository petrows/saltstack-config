
cmk-server-dir-config:
  file.directory:
    - name: {{ pillar.check_mk_server.data_dir }}
    - makedirs: True
    - user: 1000
    - group: 1000
    - mode: 775

cmk-server-notifications:
  file.recurse:
    - name: {{ pillar.check_mk_server.data_dir }}/cmk/local/share/check_mk/notifications
    - source: salt://files/check-mk/notifications
    - user: 1000
    - group: 1000
    - template: jinja
    - file_mode: 775

cmk-server-key:
  file.managed:
    - name: /srv/cmk-data/cmk_ssh
    - contents_pillar: pws_secrets:ssh_cmk_private:private
    - makedirs: True
    - user: 1000
    - group: 1000
    - mode: 600

{% import "roles/docker-compose-macro.sls" as compose %}
{{ compose.service('cmk-server') }}
