#!/bin/bash

cp -rva /srv/test/etc/* /etc/salt/
cp -rva /srv/test/keys/master_minion.pem /etc/salt/pki/master/master.pem
cp -rva /srv/test/keys/master_minion.pub /etc/salt/pki/master/master.pub

systemctl restart salt-master.service
