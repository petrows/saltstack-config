
postfix_packages:
  pkg.installed:
    - pkgs:
      - postfix
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
    - mode: 600

postfix_postmap:
  cmd.wait:
    - name: postmap /etc/postfix/sasl_passwd
    - cwd: /
    - watch:
      - file: /etc/postfix/sasl_passwd

postfix_reload:
  service.running:
    - name: postfix
    - enable: True
    - reload: True
    - watch:
      - file: /etc/postfix/sasl_passwd
      - file: /etc/postfix/main.cf
