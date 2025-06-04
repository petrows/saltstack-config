# Petro's saltstack config

My home and devices configuration

## How to fix problems of Soundcore Life Q30 under linux

[How to fix Soundcore Life Q30 under linux](README_Soundcore_q30.md)

## Apply local config

Install fish
`salt-call --local --file-root salt state.apply common.fish pillar='{"users": {"user1":1} }'`

## Configure new machine:

```bash
apt install salt-minion
echo -e "master: system.pws\nid: pws-system\n" > /etc/salt/minion
```

Master:

```bash
wget https://bootstrap.saltstack.com -O bootstrap-salt.sh
sh bootstrap-salt.sh
echo -e "master: system.pws\nid: pws-system\n" > /etc/salt/minion
```

Minion:

```bash
wget https://bootstrap.saltstack.com -O bootstrap-salt.sh
sudo sh bootstrap-salt.sh -P -A system.pws -i pws-server-name stable
```

Manual add minion
```bash
mkdir -p /etc/apt/keyrings
wget -O- https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public | gpg --dearmor > /etc/apt/keyrings/salt-archive-keyring.pgp
wget -O- https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources > /etc/apt/sources.list.d/salt.sources
apt update && apt install -y salt-minion
echo $hostname > /etc/salt/minion_id
echo "master: system.pws" > /etc/salt/minion
systemctl restart salt-minion
```

Update existing machine:

```bash
rm -rf /etc/salt/pki/minion/minion_master.pub
wget -O bootstrap-salt.sh https://bootstrap.saltstack.com
sh bootstrap-salt.sh -x python3 stable
```

## Run test machines

```bash
vagrant up master
vagrant up pws-web-vm-dev
vagrant ssh master -- sudo salt --force-color 'pws-web-vm-dev' state.apply
vagrant ssh master -- sudo salt --force-color --state-verbose=True 'pws-web-vm-dev' state.apply
```

## Nginx config

Auto-use of self-signed or Letsencrypt certs. After new web service installed run

```bash
# Regular direct mode
certbot certonly --webroot --webroot-path /var/www/letsencrypt --agree-tos -m email -d domain
# or, DNS mode
certbot certonly --manual --manual-auth-hook /etc/letsencrypt/acme-dns-auth.py --preferred-challenges dns --debug-challenges --agree-tos -m email -d domain
```

and apply config again.

## Time

NTP is not used. Used systemd (linux default)

```bash
systemctl status systemd-timesyncd
timedatectl
```

## Services

Section for services-specific

## Logging

To see log from container via journald, use:

```bash
journalctl -f -n 100 CONTAINER_NAME=Plex-dev
```

## Openhab

After docker update, call

```bash
systemctl stop openhab.service
rm -rf /srv/openhab-data/userdata/{cache,tmp}/*
systemctl start openhab.service
```

## Resillio Sync

To force new version run, call

```bash
salt pws-media cmd.run 'rm -rf /opt/rslsync'
salt pws-media state.apply
```

## Samba

To use Samba from Windows 10, apply registry file:

```bash
Windows Registry Editor Version 5.00
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters]
"AllowInsecureGuestAuth"=dword:1
```

Add user to shares:

* Add user to pillar `samba.smb_users`
* Deploy config
* Add user to SMB container:

```bash
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

```bash
/user group add name=monitoring_group policy=api,read
/user add group=monitoring_group name=user password=pwd
```

## Install MS fonts

```bash
tar -xf windows-fonts-2022-04.tgz -C /usr/share/fonts/
fc-cache -fv
```
