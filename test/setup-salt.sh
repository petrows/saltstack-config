#!/bin/bash -xe

INSTALL_TYPE=$1

# Add user `salt` with hardcoded UID
# On normal nodes we dont have this user, or it configured on early stage via salt-ssh
useradd -m --uid 2021 salt

curl -fsSL -o /etc/apt/keyrings/salt-archive-keyring-2023.gpg https://repo.saltproject.io/salt/py3/ubuntu/22.04/amd64/SALT-PROJECT-GPG-PUBKEY-2023.gpg

echo "deb [signed-by=/etc/apt/keyrings/salt-archive-keyring-2023.gpg arch=amd64] https://repo.saltproject.io/salt/py3/ubuntu/22.04/amd64/latest jammy main" | tee /etc/apt/sources.list.d/salt.list

apt update
apt install -y salt-$INSTALL_TYPE
