# FZF install
fzf-app:
  git.detached:
    - name: https://github.com/junegunn/fzf.git
    - target: /opt/fzf
    # Downgrade from 0.58 to 0.57 -> broken
    # - rev: v0.57.0
    # Revision is buggy: use direct commit!!
    - rev: 0476a65fca287a1cd17ae3cbdfd8155eb0fb40ad
    - force_clone: True
    - force_checkout: True

fzf-app-install:
  cmd.run:
    - name: "/opt/fzf/install --bin"
    - cwd: /opt/fzf
    - runas: root
    - onchanges:
      - git: fzf-app
