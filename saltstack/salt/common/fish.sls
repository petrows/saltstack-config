fish_packages:
  pkg.installed:
    - pkgs:
      - fish

{% for user, uid in pillar.get('users', {}).items() %}
{{user}}:
  cmd.run:
    - name: "echo 'User: {{uid}}'"
{% endfor %}
