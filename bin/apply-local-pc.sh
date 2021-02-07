#!/bin/bash -x

if [[ -z "$1" ]]; then
    echo "Usage: $0 <machine-id>"
    exit 1
fi

if [[ ! -d saltstack/salt ]]; then
    echo "This script must be called from repo root"
    exit 1
fi

PC_ID=$1

shift

sudo salt-call --id="$PC_ID" --state-verbose=False --config-dir local --file-root saltstack/salt --pillar-root saltstack/pillar --local state.apply $@
