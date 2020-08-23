#!/bin/bash

VM=$1

if [[ -z "$VM" ]]; then
    echo "Usage: $0 <vm-name>"
    echo "to remove VM and keys"
    exit 1
fi

vagrant ssh master -- sudo salt-key -yd $VM
vagrant destroy -f $VM
