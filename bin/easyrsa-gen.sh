#!/bin/bash -xe

DIR=$1
CLIENT=$2

if [ -z "$DIR" ] || [ -z "$CLIENT" ]; then
    echo "Usage: $0 <vpn-folder> <client-name>"
    echo "Client name will be expanded to client-<client-name>"
    exit 1
fi

DIR_SECRETS=$(readlink -f secrets/salt/files/openvpn/$DIR)
VARS=$DIR_SECRETS/vars
RSA_CMD=../easy-rsa/easyrsa

mkdir -p $DIR_SECRETS
cd $DIR_SECRETS

if [[ ! -d pki/private ]]; then
    echo "Generate PKI"
    $RSA_CMD init-pki
fi

if [[ ! -f $VARS ]]; then
    echo "Add default vars file to pki/vars"
    cp -rva ../vars $VARS
fi

if [[ ! -f pki/dh.pem ]]; then
    echo "Build DH"
    $RSA_CMD gen-dh
fi

if [[ ! -f pki/ca.crt ]]; then
    echo "Build local CA"
    (
        export EASYRSA_BATCH="yes"
        export EASYRSA_REQ_CN="CA-$DIR"
        $RSA_CMD --vars=$VARS build-ca nopass
    )
fi

if [[ ! -f pki/private/server.key ]]; then
    echo "Generate server key"
    $RSA_CMD --vars=$VARS build-server-full server nopass
fi

# Check that client cert is not exists already

if [[ -f pki/private/client-$CLIENT.key ]]; then
    echo "ERROR: Client file already exists"
    exit 2
fi

$RSA_CMD --vars=$VARS build-client-full client-$CLIENT nopass
