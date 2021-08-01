#!/bin/bash

PLUGINS=(
    netstat.linux
    nginx_status.py
    mk_docker.py
    mk_logwatch.py
)

for plugin in ${PLUGINS[@]}; do
    echo "Updating: ${plugin}"
    wget "https://cmk.system.pws/cmk/check_mk/agents/plugins/${plugin}" -O "saltstack/salt/files/check-mk/plugins/${plugin}"
done
