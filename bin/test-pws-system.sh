#!/bin/bash -e

# Up master
vagrant up master

# Up and configure host
vagrant up pws-system-dev
vagrant ssh master -- sudo salt --force-color 'pws-system-dev' state.apply

# Check service status
vagrant ssh pws-system-dev -- sudo systemctl status system-docker-compose.service

# Display check_mk password
vagrant ssh pws-system-dev -- "cd /opt/system ; sudo docker-compose logs | grep password"
