
# Web data mount
web-nfs:
  mount.mounted:
    - name: /srv/web
    - device: pve.pws:/srv/hdd2/web
    - fstype: nfs
    - mkmnt: True
    - opts:
      - defaults

wiki-nginx:
  file.managed:
    - name: /etc/nginx/conf.d/wiki.conf
    - source: salt://files/docker-compose/proxy.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    # Virtual host config:
    - config_name: wiki
    - port: 7003
    - domain:
        - wiki.petro.ws
        - wiki.web-vm.pws

# WikiMedia

wiki-rootdir:
  file.directory:
    - name:  /opt/wiki
    - makedirs: True
    - user:  root
    - group:  root
    - mode:  755

wiki-dir-images:
  file.directory:
    - name:  /opt/wiki/images
    - user:  root
    - group:  root
    - mode:  777

wiki-dir-mysql:
  file.directory:
    - name:  /opt/wiki/mysql
    - user:  999
    - group:  999
    - mode:  700

wiki-compose:
  file.managed:
    - name: /opt/wiki/docker-compose.yml
    - source: salt://files/pws-web-vm/wiki/docker-compose.yml
    - template: jinja
    - user: root
    - group: root
    - mode: 644

compose-wiki.service:
  file.managed:
    - name: /etc/systemd/system/compose-wiki.service
    - source: salt://files/docker-compose/systemd.service
    - template: jinja
    - user: root
    - group: root
    - context:
      compose_path: /opt/wiki/
  service.running:
    - enable: True
    - watch:
      - file: /opt/wiki/docker-compose.yml

