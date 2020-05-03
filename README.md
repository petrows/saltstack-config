## Apply local config

Install fish
`salt-call --local --file-root salt state.apply common.fish pillar='{"users": {"user1":1} }'`

# Configure new machine:
```
apt install salt-minion
echo -e "master: system.pws\nid: pws-system\n" > /etc/salt/minion
```
Master:
```
curl -o bootstrap-salt.sh -L https://bootstrap.saltstack.com
sh bootstrap-salt.sh
echo -e "master: system.pws\nid: pws-system\n" > /etc/salt/minion
```
Minion:
```
curl -L https://bootstrap.saltstack.com -o install_salt.sh
sudo sh install_salt.sh -P -A system.pws -i pws-server-name
```

# Run test machines
```
vagrant up master
vagrant up pws-web-vm-dev
vagrant ssh master -- sudo salt --force-color 'pws-web-vm-dev' state.apply
```

# Nginx config
Auto-use of self-signed or Letsencrypt certs. After new web service installed run
```
certbot certonly --webroot --webroot-path /var/www/letsencrypt --agree-tos -m email -d domain
```
and apply config again.
