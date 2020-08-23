#!/bin/bash

VM=$1

if [[ -z "$VM" ]]; then
    echo "Usage: $0 <vm-name>"
    echo "to up and test new VM"
    exit 1
fi

vagrant up master $VM
sleep 5
vagrant ssh master -- sudo salt --force-color $VM state.apply
