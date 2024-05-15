# Remove MOTD spam
motd-news.service:
  service.masked
motd-news.timer:
  service.masked

{% for clean_file in [ '/etc/update-motd.d/10-help-text', '/etc/update-motd.d/50-motd-news', '/etc/default/motd-news' ] %}
cleanup-files-{{ clean_file }}:
  file.absent:
    - name: {{ clean_file }}
{% endfor %}

# Required packages
fish_packages:
  pkg.installed:
    - pkgs:
      - fish
      - powerline

{% if grains['os'] != 'Raspbian' %}
vim_packages:
  pkg.installed:
    - pkgs:
      - vim-nox
      - vim-youcompleteme
{% endif %}

{% if pillar['powerline_git_pkg'] %}
fish_git_packages:
  pkg.installed:
    - pkgs:
      - {{ pillar['powerline_git_pkg'] }}
{% endif %}

# Sudo control
/etc/sudoers:
  file.managed:
    - contents: |
        # This file is managed by SALT
        Defaults env_reset
        Defaults mail_badpass
        Defaults secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"
        # User privilege specification
        root    ALL=(ALL:ALL) ALL
        # Members of the admin group may gain root privileges
        %admin  ALL=(ALL) ALL
        # Allow members of group sudo to execute any command
        %sudo   ALL=(ALL:ALL) ALL
        #includedir /etc/sudoers.d
        {%- for user_id, user in salt['pillar.get']('users', {}).items() %}
        {%- if user.sudo|default(False) %}
        {{ user_id }} ALL=(ALL) {% if user.sudo_nopassword|default(False) %}NOPASSWD{% endif %}:ALL
        {%- endif %}
        {%- endfor %}

# Drop annoying fish file from freaking snapd
/usr/share/fish/vendor_conf.d/snapd.fish:
  file.absent: []

{# sudoers-d-remove:
  file.absent:
    - name: /etc/sudoers.d #}

# Force allow Vbox to use any networks (https://stackoverflow.com/questions/70281938/docker-machine-unable-to-create-a-machine-on-macos-vboxmanage-returning-e-acces)
/etc/vbox/networks.conf:
  file.managed:
    - makedirs: True
    - contents: |
        * 0.0.0.0/0 ::/0

# Loop over allowed users on this server
{% for user_id, user in salt['pillar.get']('users', {}).items() %}

# User vars
{% set ns = namespace() %}
{% set user_groups = user.groups|default([]) %}

user_{{user_id}}_group:
  group.present:
    - name: {{ user_id }}
{% if user.get('uid') %}
    - gid: {{ user.uid }}
{% endif %}

user_{{user_id}}_config:
  user.present:
    - name: {{ user_id }}
    - home: {{ user.home }}
    - createhome: True
{% if user.get('uid') %}
    - uid: {{ user.uid }}
    - gid: {{ user.uid }}
{% endif %}
{% if user_groups %}
    - groups: {{ user_groups }}
{% endif %}
    - shell: {{ user.shell|default('/usr/bin/fish') }}
  require:
    - pkg: fish_packages

# Filter keys related to user
# key.user is a regexp for user(s) only for this key
{% set ns.ssh_keys = {} %}
{% for id, key in salt['pillar.get']('ssh:keys').items() %}
  {% set user_filter = key.user|default(False) %}
  {% if not user_filter or user_id is match(user_filter) %}
    {% do ns.ssh_keys.update({id: key}) %}
  {% endif %}
{% endfor %}

# SSH access
# Find keys to install
user_{{user_id}}_ssh_auth:
{% if pillar.ssh.force_manage %}
  ssh_auth.manage:
    - user: {{ user_id }}
    - ssh_keys:
{%- for id, key in ns.ssh_keys.items() %}
  {%- set key_data = [] %}
  {%- if key.opts|default([]) %}
    {%- set _=key_data.append(key.opts|join(',')) %}
  {%- endif %}
  {%- set _=key_data.append(key.enc) %}
  {%- set _=key_data.append(key.key) %}
  {%- set _=key_data.append(id) %}
  {%- set _=key_data.append("(saltstack)") %}
      - {{ key_data|join(' ') }}
{% endfor %}
{% else %} # pillar.ssh.force_manage
  ssh_auth.present:
    - user: {{ user_id }}
    - names:
{% for id, key in ns.ssh_keys.items() %}
  {%- set key_data = [] %}
  {%- if key.opts|default([]) %}
    {%- set _=key_data.append(key.opts|join(',')) %}
  {%- endif %}
  {%- set _=key_data.append(key.enc) %}
  {%- set _=key_data.append(key.key) %}
  {%- set _=key_data.append(id) %}
  {%- set _=key_data.append("(saltstack)") %}
      - {{ key_data|join(' ') }}
{% endfor %}
{% endif %} # pillar.ssh.force_manage

{% if user.install_profile|default(True) %}

user_{{user_id}}_fish_local:
  cmd.run:
    - name: |
        touch {{ user.home }}/.profile_local.fish
    - creates: {{ user.home }}/.profile_local.fish

# Powerline
user_{{user_id}}_fish_profile:
  file.managed:
    - name: {{user.home}}/.profile_common.fish
    - source: salt://files/linux-config/home/.profile_common.fish
    - template: jinja
    - user: {{user_id}}
    - group: {{user_id}}

user_{{user_id}}_config_dir:
  file.recurse:
    - name: {{user.home}}/.config
    - source: salt://files/linux-config/home/.config
    - template: jinja
    - user: {{user_id}}
    - group: {{user_id}}

{% if not salt['file.file_exists'](user.home + '/.config/fish/fish_variables') or pillar.force_user_update|default(False) %}
user_{{user_id}}_fish_vars_config:
  file.managed:
    - name: {{user.home}}/.config/fish/fish_variables
    - source: salt://files/linux-config/fish_variables
    - makedirs: True
    - user: {{user_id}}
    - group: {{user_id}}
{% endif %}

# FZF uninstall old pkg
fzf-clean-old-app-{{user_id}}:
  file.absent:
    - name: {{user.home}}/.fzf
fzf-clean-old-bindings-{{user_id}}:
  file.absent:
    - name: {{user.home}}/.config/fish/functions/fish_user_key_bindings.fish

# FZF install bash (new pkg)
fzf-app-install-bash-{{user_id}}:
  file.append:
    - name: {{user.home}}/.bashrc
    - text: '[ -f ~/.fzf.bash ] && source ~/.fzf.bash'
fzf-app-install-bash-{{user_id}}-launcher:
  file.managed:
    - name: {{user.home}}/.fzf.bash
    - source: salt://files/linux-config/home/.fzf.bash
    - user: {{user_id}}
    - group: {{user_id}}
    - mode: 755

user_{{user_id}}_vim_config:
  file.managed:
    - name: {{user.home}}/.vimrc
    - source: salt://files/linux-config/home/.vimrc
    - user: {{user_id}}
    - group: {{user_id}}

user_{{user_id}}_vim_autoload:
  file.directory:
    - name: {{user.home}}/.vim/autoload
    - makedirs: True
    - user: {{user_id}}
    - group: {{user_id}}

user_{{user_id}}_xsession:
  file.managed:
    - name: {{user.home}}/.xsessionrc
    - source: salt://files/linux-config/home/sessionrc.sh
    - template: jinja
    - user: {{user_id}}
    - group: {{user_id}}

# VIM plug install
user_{{user_id}}_vim_plug_deploy:
  file.managed:
    - name: {{user.home}}/.vim/autoload/plug.vim
    - source: https://raw.githubusercontent.com/junegunn/vim-plug/0.10.0/plug.vim
    - skip_verify: True
    - user: {{user_id}}
    - group: {{user_id}}

# Ignore errors on vim setup
user_{{user_id}}_vim_plug:
  cmd.run:
    - name: "vim -E -s -u '{{ user.home }}/.vimrc' -c 'PlugInstall --sync' -c 'qall'; true"
    - cwd: {{user.home}}
    - runas: {{user_id}}
    - creates:
      - {{user.home}}/.vim/plugged

# Git configuration

{% for config_key, config_value in salt['pillar.get']('git_config', {}).items() %}
user_{{user_id}}_git_{{config_key}}:
  git.config_set:
    - name: {{config_key}}
    - value: "{{config_value}}"
    - global: True
    - user: {{user_id}}
# Git config
{% endfor %}

{% endif %} # if user.install_profile

{% endfor %}
