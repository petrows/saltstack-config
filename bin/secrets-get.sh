#!/bin/bash

if [[ ! -d secrets/.git ]]; then
    git clone ssh://root@system.pws/srv/salt-config/secrets secrets
fi

cd secrets

git checkout -f master
git pull
