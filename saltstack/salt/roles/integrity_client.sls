# This file manages the script,
# to check that honeypots are not damaged

{% for target_name, target_enabled in salt['pillar.get']('integrity:check_targets', {}).items() %}
{% if target_enabled %}
/etc/pws/integrity-{{ target_name }}.json:
  file.managed:
    - contents: |
        {{ salt['pillar.get']('integrity:'+target_name) | json }}
    - makedirs: True
    - mode: 700
{% endif %}
{% endfor %}
