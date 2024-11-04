#!/bin/bash -xe

INSTALL_TYPE=$1

# Add user `salt` with hardcoded UID
# On normal nodes we dont have this user, or it configured on early stage via salt-ssh
useradd -m --uid 2021 salt

curl -fsSL -o /etc/apt/keyrings/salt-archive-keyring-2023.pgp https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public

echo "deb [signed-by=/etc/apt/keyrings/salt-archive-keyring-2023.pgp arch=amd64] https://packages.broadcom.com/artifactory/saltproject-deb/ stable main" | tee /etc/apt/sources.list.d/saltstack.list

apt update
apt install -y salt-$INSTALL_TYPE
