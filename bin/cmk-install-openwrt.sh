#!/bin/bash -xe

HOST=$1

if [[ -z "$1" ]]; then
    echo "Usage $0 <hostname>"
    exit 1
fi

echo "Installing CMK Agent for OpenWRT $0"

ssh root@$HOST opkg update
ssh root@$HOST opkg install xinetd ethtool openssh-sftp-server

scp -r saltstack/salt/files/openwrt/* root@$HOST:/
scp -r saltstack/salt/packages/check_mk_agent.openwrt root@$HOST:/usr/sbin/check_mk_agent

ssh root@$HOST /etc/init.d/xinetd restart
