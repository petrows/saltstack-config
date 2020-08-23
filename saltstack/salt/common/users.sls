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

# Loop over allowed users on this server
{% for user_id, user in salt.pillar.get('users', {}).items() %}

user_{{user_id}}_group:
  group.present:
    - name: {{ user_id }}
{% if user.uid %}
    - gid: {{ user.uid }}
{% endif %}

user_{{user_id}}_config:
  user.present:
    - name: {{ user_id }}
    - home: {{ user.home }}
{% if user.uid %}
    - uid: {{ user.uid }}
{% endif %}
    - groups:
      - {{ user_id }}
    - shell: /usr/bin/fish
  require:
    - pkg: fish_packages

user_{{user_id}}_fish_local:
  cmd.run:
    - name: |
        touch {{ user.home }}/.profile_local.fish
    - creates: {{ user.home }}/.profile_local.fish

# SSH access
{% for ssh_key in salt.pillar.get('ssh:keys', []) %}
user_{{user_id}}_ssh_{{ ssh_key }}:
  ssh_auth.present:
    - user: {{ user_id }}
    - name: {{ ssh_key }}
{% endfor %}

# Powerline
user_{{user_id}}_fish_profile:
  file.managed:
    - name: {{user.home}}/.profile_common.fish
    - source: salt://files/linux-config/home/.profile_common.fish
    - template: jinja
    - user: {{user_id}}
    - group: {{user_id}}

user_{{user_id}}_fish_powerline:
  file.recurse:
    - name: {{user.home}}/.config
    - source: salt://files/linux-config/home/.config
    - template: jinja
    - user: {{user_id}}
    - group: {{user_id}}

{% if not salt['file.file_exists'](user.home + '/.config/fish/fish_variables') %}
user_{{user_id}}_fish_vars_config:
  file.managed:
    - name: {{user.home}}/.config/fish/fish_variables
    - source: salt://files/linux-config/fish_variables
    - makedirs: True
    - user: {{user_id}}
    - group: {{user_id}}
{% endif %}

# FZF install
user_{{user_id}}_fzf_src:
  git.latest:
    - user: {{user_id}}
    - name: https://github.com/junegunn/fzf.git
    - target: {{user.home}}/.fzf
    - force_fetch: True
    - force_reset: True

user_{{user_id}}_fzf_config:
  cmd.run:
    - name: "{{user.home}}/.fzf/install --all"
    - cwd: {{user.home}}
    - runas: {{user_id}}
    - onchanges:
      - git: user_{{user_id}}_fzf_src

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

# VIM plug install
user_{{user_id}}_vim_plug_deploy:
  file.managed:
    - name: {{user.home}}/.vim/autoload/plug.vim
    - source: https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
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

{% for config_key, config_value in salt.pillar.get('git_config', {}).items() %}
user_{{user_id}}_git_{{config_key}}:
  git.config_set:
    - name: {{config_key}}
    - value: "{{config_value}}"
    - global: True
    - user: {{user_id}}
# Git config
{% endfor %}

{% endfor %}
