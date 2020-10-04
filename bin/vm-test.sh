#!/bin/bash -x

VM=$1

if [[ -z "$VM" ]]; then
    echo "Usage: $0 <vm-name>"
    echo "to up and test new VM"
    exit 1
fi

vagrant up master

# Clean all keys
vagrant ssh master -- sudo salt-key -yd '*'

# Reload - if there were already up VM's to force reconnect
vagrant ssh master -- sudo service salt-master restart

vagrant halt $VM
vagrant up $VM
sleep 5
vagrant ssh master -- sudo salt --force-color $VM state.apply
