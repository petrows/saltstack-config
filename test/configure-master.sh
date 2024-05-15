#!/bin/bash -xe

cp -rva /vg/test/etc/* /etc/salt/
cp -rva /vg/test/keys/master_minion.pem /etc/salt/pki/master/master.pem
cp -rva /vg/test/keys/master_minion.pub /etc/salt/pki/master/master.pub

# Cleanup keys
salt-key -yd '*'

systemctl restart salt-master.service
