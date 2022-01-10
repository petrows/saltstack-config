# Default pillar values

timezone: Europe/Berlin

# Mount /tmp as ramdisk?
tmp_ramdisk: False

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

# check-mk settings
check_mk_agent:
  install: False
  base: https://cmk.system.pws/cmk/check_mk/agents/
  filename: check-mk-agent_2.0.0p9-1_all.deb
  checksum: 319a73e06057a792d22cc429e099fd46

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

docker:
  subnet: 172.16.0.0/12
  subnet_size: 24
  ipv6_cidr: fdfd:8b2c:086d:ecbd::/64

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
  alias.cln: "!f() { git submodule update; git submodule sync; git reset --hard --recurse-submodule; git clean -fd; }; f"
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
  alias.sub-clean: "!f() { git submodule foreach rm -rf .git *; }; f"

# SSH keys for all users to be installed
# ssh:
#  keys:
#    <key-id>: # Name of key
#      type: <type:ssh-ed25519> # Type, same as in .pub
#      key: ...
ssh:
  force_manage: True # Erase keys not exists?
  keys:
    petro@petro.ws:
      enc: ssh-ed25519
      key: AAAAC3NzaC1lZDI1NTE5AAAAIDuBa7ob9ADp3XvpLKFW8tEkoD0gK+Fg0JKzTX36yndl
    petro@work:
      enc: ssh-ed25519
      key: AAAAC3NzaC1lZDI1NTE5AAAAIAUb4j91LRd0dBXMj+QE9uhC1MaKZXz5s5u64ld3uTay
    salt@pws: # See saltstack/pillar/pws/secrets.sls
      user: ^salt$
      enc: ssh-ed25519
      key: AAAAC3NzaC1lZDI1NTE5AAAAINvleX9wOOd2C5M7Wy3sv2XSCXRvYG8iY+U4ONZBueYi

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

# https://github.com/telegramdesktop/tdesktop/releases
telegram:
  version: 3.2.0

xsession:
  gtk_scale: 1.0

# i3 config options
i3:
  bar_font_size: 12
  display: ''
  startup: ''
  # Where to read CPU package temperature
  temp_read: /sys/devices/platform/coretemp.0/hwmon/hwmon1/temp1_input

swap_size_mb: 0

network:
  type: unknown
  ntp: False
  dns: False

users: {}

mount-folders: {}

nfs-exports: {}

# meta pillar for simple systemd 'crontab'
# avaliable options are:
# calendar - equation when to run
# user - user to set in unit
# cmd - command to call (will be called as /bin/bash -c '<cmd>')
# cwd - workdir
systemd-cron: {}

# Export static registry as pillar to be used in SLS
{% import_yaml 'static.yaml' as static %}
static: {{ static|yaml }}
