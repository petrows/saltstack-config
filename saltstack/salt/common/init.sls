include:
  - common.packages

us_locale:
  locale.present:
    - name: en_US.UTF-8

ru_RU.UTF-8:
  locale.present

de_DE.UTF-8:
  locale.present

default_locale:
  locale.system:
    - name: en_US.UTF-8
    - require:
      - locale: us_locale

{% if pillar['maintainer_email'] %}
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
{% endif %}
