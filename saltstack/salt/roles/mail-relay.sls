
postfix_packages:
  pkg.installed:
    - pkgs:
      - postfix
      - libsasl2-2
      - libsasl2-modules
      - mailutils

postfix_conf:
  file.recurse:
    - name: /etc/postfix/
    - source: salt://files/mail-relay/
    - template: jinja
    - user: root
    - group: root
    - file_mode: 600

postfix_postmap:
  cmd.wait:
    - name: postmap /etc/postfix/sasl_passwd
    - cwd: /
    - watch:
      - file: postfix_conf

# Postfix virtual maps
# This will force ALL @domain to be sent to one address
# https://serverfault.com/questions/144325/how-to-redirect-all-postfix-emails-to-one-external-email-address
{% set minion_hostname = salt['cmd.shell']('cat /etc/hostname', shell='/bin/bash') %}
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
      - file: postfix_conf
      - pkg: postfix_packages

# This maps will redirect local mailbox emails,
# eq sent to root@localhost

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
