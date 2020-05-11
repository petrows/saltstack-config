#!/bin/bash

if [[ -z "$1" ]]; then
    echo "Usage: $0 <machine-id>"
    exit 1
fi

if [[ ! -d saltstack/salt ]]; then
    echo "This script must be called from repo root"
    exit 1
fi

sudo salt-call --id="$1" --file-root saltstack/salt --pillar-root saltstack/pillar --local state.apply
