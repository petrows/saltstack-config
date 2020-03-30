# Default pillar values

# Use 'powerline.segments.common.vcs.branch' for old systems
powerline_git_plugin: 'powerline_gitstatus.gitstatus'
powerline_git_pkg: 'powerline-gitstatus'

git_config:
  core.whitespace: fix, trailing-space
  color.ui: auto
  push.default: tracking
  pull.rebase: "true"
  alias.ca: commit -am
  alias.l: "log --graph --decorate --pretty=format:'%C(yellow)%h%Creset %s %C(green)(%cr)%Creset' --abbrev-commit --date=relative"
  alias.s: status --short
  alias.checkout-pr: "!f() { git fetch origin pull/$1/head:pr-$1 && git checkout pr-$1; }; f"
  alias.ch: "!f() { git fetch; git checkout -f --recursive-submodules $1; }; f"
