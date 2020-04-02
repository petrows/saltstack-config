## Apply local config

Install fish 
`salt-call --local --file-root salt state.apply common.fish pillar='{"users": {"user1":1} }'`

# Configure new machine:
```
apt install salt-minion
echo -e "master: system.pws\nid: pws-system\n" > /etc/salt/minion
```
```
curl -o bootstrap-salt.sh -L https://bootstrap.saltstack.com
sh bootstrap-salt.sh
echo -e "master: system.pws\nid: pws-system\n" > /etc/salt/minion
```

# Run test machines
```
vagrant up master
vagrant up pws-web-vm-dev
vagrant ssh master -- sudo salt --force-color 'pws-web-vm-dev' state.apply
```