#!/bin/bash -e

# Up master
vagrant up master

# Up and configure host
vagrant up pws-web-vm-dev
vagrant ssh master -- sudo salt --force-color 'pws-web-vm-dev' state.apply
