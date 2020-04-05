# -*- mode: ruby -*-
# vi: set ft=ruby :

# Template and test scripts from
# https://github.com/UtahDave/salt-vagrant-demo

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  os = "bento/ubuntu-18.04"
  net_ip = "10.99.99"

  # ============================================================================================
  # Salt master config

  config.vm.define :master, primary: true do |master_config|
    master_config.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = 4
      vb.name = "master"
    end

    master_config.vm.box = "#{os}"
    master_config.vm.host_name = "saltmaster.local"
    master_config.vm.network "private_network", ip: "#{net_ip}.10"
    master_config.vm.synced_folder "saltstack/salt/", "/srv/salt"
    master_config.vm.synced_folder "saltstack/pillar/", "/srv/pillar"

    master_config.vm.provision :salt do |salt|
      salt.master_config = "saltstack/etc/master"
      salt.master_key = "saltstack/keys/master_minion.pem"
      salt.master_pub = "saltstack/keys/master_minion.pub"
      salt.minion_key = "saltstack/keys/master_minion.pem"
      salt.minion_pub = "saltstack/keys/master_minion.pub"
      salt.seed_master = {
        "pws-system-dev" => "saltstack/keys/pws-system-dev.pub",
        "pws-pve-dev" => "saltstack/keys/pws-pve-dev.pub",
      }

      salt.install_type = "stable"
      salt.install_master = true
      salt.no_minion = true
      salt.verbose = true
      salt.colorize = true
      salt.bootstrap_options = "-x python3 -P -c /tmp"
    end
  end

  # ============================================================================================
  # Salt minion config

  [
    ["pws-system-dev", "#{net_ip}.12", "1024", os],
    ["pws-pve-dev", "#{net_ip}.13", "1024", "debian/stretch64"],
    ["pws-web-vm-dev", "#{net_ip}.14", "1024", "debian/stretch64"],
    ["pws-backup-dev", "#{net_ip}.15", "1024", "debian/buster64"],
  ].each do |vmname, ip, mem, os|
    config.vm.define "#{vmname}" do |minion_config|
      minion_config.vm.provider "virtualbox" do |vb|
        vb.memory = "#{mem}"
        vb.cpus = 4
        vb.name = "#{vmname}"
      end

      minion_config.vm.box = "#{os}"
      minion_config.vm.hostname = "#{vmname}"
      minion_config.vm.network "private_network", ip: "#{ip}"

      minion_config.vm.provision :salt do |salt|
        salt.minion_config = "saltstack/etc/#{vmname}"
        salt.minion_key = "saltstack/keys/#{vmname}.pem"
        salt.minion_pub = "saltstack/keys/#{vmname}.pub"
        salt.install_type = "stable"
        salt.verbose = true
        salt.colorize = true
        salt.bootstrap_options = "-x python3 -P -c /tmp"
      end
    end
  end

  # ============================================================================================
  # Salt local test config

  config.vm.define "salt-local" do |local_config|
    local_config.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = 4
      vb.name = "local-salt"
    end

    local_config.vm.box = "#{os}"
    local_config.vm.host_name = "salt-local.local"
    local_config.vm.network "private_network", ip: "#{net_ip}.11"
    local_config.vm.synced_folder ".", "/srv/salt"

    local_config.vm.provision :salt do |salt|
      salt.masterless = true
      salt.verbose = true
      salt.colorize = true
      salt.bootstrap_options = "-x python3 -P -c /tmp"
    end
  end
end
