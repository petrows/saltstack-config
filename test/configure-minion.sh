#!/bin/bash

MASTER_IP=$1
MINION_ID=$2

echo "Apply custom config for dev-minion, id = ${MINION_ID}, master = ${MASTER_IP}"

echo $MINION_ID>/etc/salt/minion_id

tee /etc/salt/minion <<EOT
# Master to connect
master: ${MASTER_IP}
# Enable some logging for watch
log_level: info
log_file: /var/log/salt/minion
EOT

systemctl restart salt-minion.service
