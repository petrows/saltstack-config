# https://hub.docker.com/r/adguard/adguardhome
#
# Privacy protection center for you and your devices
# Free and open source, powerful network-wide ads & trackers blocking DNS server.

{% for dir,uid in {'work':0,'work':0}.items() %}
adguard-dir-{{ dir }}:
  file.directory:
    - name: {{ pillar.adguard.data_dir }}/{{ dir }}
    - makedirs: True
    - user: {{ uid }}
    - group: {{ uid }}
    - mode:  755
{% endfor %}

# Deactivate DNSStubListener to free 53 port

/etc/systemd/resolved.conf.d/adguardhome.conf:
  file.managed:
    - makedirs: True
    - contents: |
        [Resolve]
        DNS=127.0.0.1
        DNSStubListener=no

restart-resolved:
  cmd.wait:
    - name: systemctl reload-or-restart systemd-resolved.service
    - watch:
      - file: /etc/systemd/resolved.conf.d/adguardhome.conf

{% import "roles/docker-compose-macro.sls" as compose %}
{{ compose.service('adguard') }}
