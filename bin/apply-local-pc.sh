#!/bin/bash -x

if [[ -z "$1" ]]; then
    echo "Usage: $0 <machine-id> state.apply test=true"
    exit 1
fi

if [[ ! -d saltstack/salt ]]; then
    echo "This script must be called from repo root"
    exit 1
fi

mkdir -p tmp/salt-local
cat local/minion | envsubst > tmp/salt-local/minion

PC_ID=$1

shift

sudo -E env PATH=$PATH salt-call \
    --id="$PC_ID" \
    --state-verbose=False \
    --config-dir tmp/salt-local \
    --local \
    $@
