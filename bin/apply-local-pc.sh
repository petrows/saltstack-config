#!/bin/bash

if [[ -z "$1" ]]; then
    echo "Usage: $0 <machine-id>"
    exit 1
fi

sudo salt-call --id="$1" --file-root salt --pillar-root pillar --local state.apply
