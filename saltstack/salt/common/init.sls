include:
  - common.packages

locale-us:
  locale.present:
    - name: en_US.UTF-8

ru_RU.UTF-8:
  locale.present

de_DE.UTF-8:
  locale.present

locale-default:
  locale.system:
    - name: en_US.UTF-8
    - require:
      - locale: locale-us

default-timezone:
  timezone.system:
    - name: Europe/Berlin

{% if salt.pillar.get('maintainer_email', '') != '' %}
mail_alias_maintainer:
  file.managed:
    - name: /etc/aliases
    - source: salt://files/mail-aliases
    - template: jinja

mail_alias_maintainer_db:
  cmd.run:
    - name: newaliases
    - onchanges:
      - file: /etc/aliases
    - requre:
      - pkg:
        - mail-tools
{% endif %}
