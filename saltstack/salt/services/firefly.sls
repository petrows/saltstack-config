
{{ pillar.firefly.data_dir }}/upload:
  file.directory:
    - makedirs: True
    - user: 33
    - group: 33
    - mode: 775

{{ pillar.firefly.data_dir }}/db:
  file.directory:
    - user:  999
    - group:  999
    - mode:  700

bank-scripts:
  file.recurse:
    - name: /srv/bank
    - source: salt://files/bank
    - template: jinja
    - user: master
    - group: master

{% for dir in ['cfg','data', 'data/backup'] %}
/srv/bank/{{ dir }}:
  file.directory:
    - makedirs: True
    - user: master
    - group: master
    - mode:  700
{% endfor %}

/srv/bank/cfg/firefly.json:
  file.serialize:
    - serializer: json
    - dataset_pillar: 'pws_secrets:firefly'

/srv/bank/cfg/nordigen.json:
  file.serialize:
    - serializer: json
    - dataset_pillar: 'pws_secrets:nordigen'

/srv/bank/.env:
  virtualenv.managed:
    - user: master
    - system_site_packages: False
    - requirements: salt://files/bank/requirements.txt

{% import "roles/docker-compose-macro.sls" as compose %}
{{ compose.service('firefly') }}
