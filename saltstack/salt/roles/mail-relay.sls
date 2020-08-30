
postfix_packages:
  pkg.installed:
    - pkgs:
      - postfix
      - libsasl2-2
      - libsasl2-modules
      - mailutils

postfix_sasl:
  file.managed:
    - name: /etc/postfix/sasl_passwd
    - source: salt://files/mail-relay/sasl_passwd
    - template: jinja
    - user: root
    - group: root
    - mode: 600

postfix_conf:
  file.managed:
    - name: /etc/postfix/main.cf
    - source: salt://files/mail-relay/mail.cf
    - template: jinja
    - user: root
    - group: root
    - mode: 644

postfix_postmap:
  cmd.wait:
    - name: postmap /etc/postfix/sasl_passwd
    - cwd: /
    - watch:
      - file: /etc/postfix/sasl_passwd

# Postfix virtual maps
# This will force ALL @domain to be sent to one address
# https://serverfault.com/questions/144325/how-to-redirect-all-postfix-emails-to-one-external-email-address
{% set minion_hostname = salt['cmd.shell']('cat /etc/hostname') %}
postfix_virtal_map:
  file.managed:
    - name: /etc/postfix/virtual-regexp
    - contents: |
        /.+@{{ minion_hostname }}/ {{ pillar.maintainer_email }}
  cmd.wait:
    - name: postmap /etc/postfix/virtual-regexp
    - watch:
      - file: /etc/postfix/virtual-regexp

postfix_reload:
  service.running:
    - name: postfix
    - enable: True
    - reload: True
    - watch:
      - file: /etc/postfix/*
      - pkg: postfix_packages
