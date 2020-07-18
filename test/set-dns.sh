#!/bin/bash -xe

ips_list=$1
echo "Will enforce DNS servers: $ips_list"

ips_spaced="${ips_list//,/ }"

# Set systemd-resolve DNS
if [[ -f /etc/systemd/resolved.conf ]]; then
    echo "Update resolved.conf"
    sed -i "s/^#\?DNS=.*/DNS=$ips_spaced/g; s/^#\?DNSSEC=.*/DNSSEC=no/g" /etc/systemd/resolved.conf
    systemctl daemon-reload
    systemctl restart systemd-resolved
fi

# Set DNS config for netplan
if [[ -f /etc/netplan/01-netcfg.yaml ]]; then
    echo "Update netplan"
    sed -i 's/addresses:.*/addresses: ['$ips_list']/g' /etc/netplan/01-netcfg.yaml
    netplan generate
    netplan apply
fi
