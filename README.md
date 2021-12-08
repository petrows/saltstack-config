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
curl -L https://bootstrap.saltstack.com -o bootstrap-salt.sh
sudo sh bootstrap-salt.sh -P -A system.pws -i pws-server-name stable
```
Update existing machine:
```
rm -rf /etc/salt/pki/minion/minion_master.pub
wget -O bootstrap-salt.sh https://bootstrap.saltstack.com
sh bootstrap-salt.sh -x python3 stable
```

# Run test machines
```
vagrant up master
vagrant up pws-web-vm-dev
vagrant ssh master -- sudo salt --force-color 'pws-web-vm-dev' state.apply
vagrant ssh master -- sudo salt --force-color --state-verbose=True 'pws-web-vm-dev' state.apply
```

# Nginx config
Auto-use of self-signed or Letsencrypt certs. After new web service installed run
```
certbot certonly --webroot --webroot-path /var/www/letsencrypt --agree-tos -m email -d domain
```
and apply config again.

# Time
NTP is not used. Used systemd (linux default)
```
systemctl status systemd-timesyncd
timedatectl
```

# Services
Section for services-specific
## Logging
To see log from container via journald, use:
```
journalctl -f -n 100 CONTAINER_NAME=Plex-dev
```

## Openhab
After docker update, call
```
systemctl stop openhab.service
rm -rf /srv/openhab-data/userdata/{cache,tmp}/*
systemctl start openhab.service
```
## Resillio Sync
To force new version run, call
```
salt pws-media cmd.run 'rm -rf /opt/rslsync'
salt pws-media state.apply
```
## Samba
To use Samba from Windows 10, apply registry file:
```
Windows Registry Editor Version 5.00
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters]
"AllowInsecureGuestAuth"=dword:1
```
Add user to shares:
```
docker exec -it Samba smbpasswd -a master
```

## Generate new OpenVPN profile

Basic usage:

```bash
./bin/secrets-get.sh
./bin/easyrsa-gen.sh <server-name> <client-name>
```

Initalize **new** secrets folder:

```bash
./bin/secrets-get.sh
sudo apt install easy-rsa
mkdir -p secrets/salt/files/openvpn/
cp -rva /usr/share/easy-rsa secrets/salt/files/openvpn/
```

## Mikrotik monitoring

Add user:

```
/user group add name=monitoring_group policy=api,read
/user add group=monitoring_group name=user password=pwd
```
