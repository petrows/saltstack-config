

fish_packages:
  pkg.installed:
    - pkgs:
      - net-tools
      - vim
      - vim-nox
      - vim-youcompleteme
      - git
      - python3
      - python3-pip
      - python3-git
      - curl
      - wget
      - screen
      - mc
      - fish
      - powerline

{% for user_id, user in pillar.get('users', {}).items() %}
user_{{user_id}}_group:
  group.present:
    - name: {{ user_id }}
    - gid: {{ user.uid }}
user_{{user_id}}_config:
  user.present:
    - name: {{ user_id }}
    - home: {{ user.home }}
    - uid: {{ user.uid }}
    - gid: {{ user.uid }}
    - shell: /usr/bin/fish
  require:
    - pkg: fish_packages

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

# FZF install
user_{{user_id}}_fzf_src:
  git.latest:
    - user: {{user_id}}
    - name: https://github.com/junegunn/fzf.git
    - target: {{user.home}}/.fzf
    #- depth: 1 # too new

user_{{user_id}}_fzf_config:
  cmd.run:
    - name: "{{user.home}}/.fzf/install --all"
    - cwd: {{user.home}}
    - runas: {{user_id}}
    - creates:
      - {{user.home}}/.fzf.bash

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

user_{{user_id}}_vim_plug:
  cmd.run:
    - name: "vim -E -s -u '{{ user.home }}/.vimrc' -c 'PlugInstall --sync' -c 'qall'"
    - cwd: {{user.home}}
    - runas: {{user_id}}
    - creates:
      - {{user.home}}/.vim/plugged
{% endfor %}
