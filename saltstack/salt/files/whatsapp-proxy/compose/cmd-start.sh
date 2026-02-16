#!/bin/bash -xe
# Script to prepare environment for whatsapp-proxy

{% set cfg = salt['pillar.get']('whatsapp-proxy', {}) %}

echo "Preparing environment for whatsapp-proxy"
{% if cfg.get('local_interface') %}
echo "Adding IP address {{ cfg.get('local_ip', '') }} to interface {{ cfg.get('local_interface') }}"
ip link | grep {{ cfg.get('local_interface') }} && ifconfig {{ cfg.get('local_interface') }} down || ip link add {{ cfg.get('local_interface') }} type dummy
ifconfig {{ cfg.get('local_interface') }} {{ cfg.get('local_ip', '') }} netmask 255.255.255.255 up
{% endif %}
