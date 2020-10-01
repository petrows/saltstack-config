# FZF install
fzf-app:
  git.latest:
    - name: https://github.com/junegunn/fzf.git
    - target: /opt/fzf
    - force_fetch: True
    - force_reset: True

fzf-app-install:
  cmd.run:
    - name: "/opt/fzf/install --bin"
    - cwd: /opt/fzf
    - runas: root
    - onchanges:
      - git: fzf-app
