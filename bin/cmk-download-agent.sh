#!/bin/bash

FILENAME=$(grep -o -P 'check-mk-agent_.*\.deb' saltstack/pillar/static.yaml | head -n 1)

mkdir -p saltstack/salt/packages

wget https://cmk.system.pws/cmk/check_mk/agents/$FILENAME -O saltstack/salt/packages/$FILENAME
wget https://cmk.system.pws/cmk/check_mk/agents/check_mk_agent.openwrt -O saltstack/salt/packages/check_mk_agent.openwrt

chmod +x saltstack/salt/packages/check_mk_agent.openwrt
