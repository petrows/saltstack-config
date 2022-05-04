#!/bin/bash

echo "Apply custom config for dev-minion"

mkdir -p /etc/salt/minion.d

tee -a /etc/salt/minion.d/99-vm.conf <<EOT
# Enable some logging for watch
log_level: info
EOT
