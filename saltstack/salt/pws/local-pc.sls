# Additional scripts
local-pc-custom-bin:
  file.recurse:
    - name: /usr/local/sbin
    - source: salt://files/linux-config/bin-local-pc
    - template: jinja
    - file_mode: 755

local-pc-soft:
  pkg.latest:
    - pkgs:
      - i3
      - compton
      - udiskie
      - rofi
      - feh
      - network-manager-gnome
      - numlockx

# Loop over allowed users on this server
{% for user_id, user in salt.pillar.get('users', {}).items() %}
local-pc-configs-{{ user_id }}:
  file.recurse:
    - name: {{user.home}}/.config
    - source: salt://files/linux-config/home-local-pc/.config
    - template: jinja
    - user: {{user_id}}
    - group: {{user_id}}
{% endfor %}
