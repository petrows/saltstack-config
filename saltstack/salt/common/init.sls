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
