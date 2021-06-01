# Default pillar values

timezone: Europe/Berlin

# Additional software
packages: []
packages_pip3: []

# PIP3 location
pip3_bin: /usr/bin/pip3

# Use 'powerline.segments.common.vcs.branch' for old systems
powerline_git_plugin: 'powerline.segments.common.vcs.branch'
powerline_git_pkg: ''

# If check-mk used, we can install additional plugins to monitor it
check_mk_plugins: {}

# If set, salt will be armed to auto-apply on connect (default for servers)
salt_auto_apply: False

# All local emails will be delivered to this one
maintainer_email: petro@petro.ws

# Docker-compose config
docker_compose:
  url: https://github.com/docker/compose/releases/download/1.26.2/docker-compose-Linux-x86_64
  sha256: 13e50875393decdb047993c3c0192b0a3825613e6dfc0fa271efed4f5dbdd6eb
  # Services to be auto-added to run
  services: {}

# This option forces to update bash / fish profile
force_user_update: False

# Values to ge set as git config for all users passed in 'users' role
git_config:
  core.whitespace: fix, trailing-space
  color.ui: auto
  push.default: tracking
  pull.rebase: "true"
  alias.ca: commit -am
  alias.cap: "commit --author='Petro <petro@petro.ws>' -am"
  alias.l: "log --graph --decorate --pretty=format:'%C(yellow)%h%Creset %s %C(green)(%cr)%Creset' --abbrev-commit --date=relative"
  alias.s: status --short
  alias.checkout-pr: "!f() { git fetch origin pull/$1/head:pr-$1 && git checkout pr-$1; }; f"
  alias.cln: "!f() { git submodule update; git clean -fd; git checkout .; }; f"
  alias.ch: "!f() { git fetch; git checkout -f --recursive-submodules $1; }; f"
  alias.pb: push --set-upstream origin HEAD
  alias.pf: push --force
  alias.d: diff
  alias.dh: diff HEAD
  alias.ds: diff --cached
  alias.wdiff: diff --color-words --ignore-all-space
  alias.co: checkout
  alias.unstage: reset HEAD
  alias.undo: checkout --

# SSH keys for all users to be installed
ssh:
  keys:
    - 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCZdDx+dLw8B7cu/OQRMA+R/o1pnlGN7WSAsiN87Ek//lr8nHociMbNWFk/e6eCWUZnJiWuDQjmFUyt/Ri7RdDCffCMbu2g6xpLCVxL3x1FE0D8rYrXFkEPNspNz9hHHpEt3WeolJenUf45ppNBTcHkUyDpQd/iTCDmiiz6I6K34QbkyAhlCEWwmlKusn85XXZiwJXEMUcLTQnmH+T1LvbZnuog8WRIDarN1smV2Sr4qa4t6MdV9cD4RuQovZQvLjmbHz/Jxl+5o6vjuXXI8Myke3r4ykXstbezdE6cqrh83AyK7YYNEypGMRx4CXUKHHfKYi46IeRMvtF6HcsLCgSZ petro@petro.ws'
    - 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC857drdwoS/R5M2Z2DvuvGzaYhd71V9j3wbmoJkNy8ZFY2j0zlbX7EsWccGJBHBIgeH3F3A3a00M4gVAMwmDm5tSE7uiq5592Wf+nr6uwAyAeT+YW/4nzbqkCV0eEhDLQ7VcErsktbNkbFi71hc5C/v9+vu+toSs6O3C0j2W8auEYBb8vXAMLtAoIbtkbwDy18dpJIdLaRiHYZJ2s6r6chFHY0NT1x6ALNAWGYBwL9Rgsm2njLcH6cRd1e2+F3V5JfoXsc0dywVX7wyCoAdwQH6jkw2a0GDmSy4bHkdbIJu7E+kqRLoOJZpSo0PCrRgu8zbMBOJ4MwT9GtnVDyWW9V petro@work'

nginx:
  # Force generate new dhparm keys for Nginx (required for external servers)
  dhparam: False

php:
  # PHP version avaliable in packages, to be replaced by grains-driven pillar
  version: 7.3
  # User to run pool under
  user_sock: www-data
  # User to own process (but NOT socket)
  user: www
  # chroot base dir
  home: /home/www
  # Pool filename in /etc/php/<version>/fpm/pool.d/
  pool_name: www

xsession:
  gtk_scale: 1.0

# Export static registry as pillar to be used in SLS
{% import_yaml 'static.yaml' as static %}
static: {{ static|yaml }}
