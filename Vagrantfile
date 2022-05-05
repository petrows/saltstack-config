# -*- mode: ruby -*-
# vi: set ft=ruby :

# Template and test scripts from
# https://github.com/UtahDave/salt-vagrant-demo

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

def cpu_count
  require "etc"
  Etc.nprocessors
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  os_u18 = "bento/ubuntu-18.04"
  os_u20 = "bento/ubuntu-20.04"
  os_d10 = "debian/buster64"
  os_d11 = "debian/bullseye64"
  os_ram = 2048
  net_ip = "10.99.99"
  net_dns_ip = "10.99.99.1,10.99.99.254"

  # ============================================================================================
  # Salt master config

  config.vm.define :master, primary: true do |master_config|
    master_config.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = cpu_count / 2
      vb.name = "master"
    end

master_config.vm.box = "#{os_u20}"
    master_config.vm.host_name = "saltmaster.local"
    master_config.vm.network "private_network", ip: "#{net_ip}.10"
    master_config.vm.synced_folder "saltstack/salt/", "/srv/salt"
    master_config.vm.synced_folder "saltstack/pillar/", "/srv/pillar"
    if FileTest::directory?("secrets/")
      master_config.vm.synced_folder "secrets/", "/srv/secrets"
    end

    master_config.vm.provision :shell, run: "once", path: "test/set-dns.sh", args: net_dns_ip

    # Do not update VBox additions (VBox only) - speedup of machine creation
    if Vagrant.has_plugin?("vagrant-vbguest")
      master_config.vbguest.auto_update = false
    end

    master_config.vm.provision :salt do |salt|
      salt.master_config = "test/etc/master"
      salt.master_key = "test/keys/master_minion.pem"
      salt.master_pub = "test/keys/master_minion.pub"
      salt.minion_key = "test/keys/master_minion.pem"
      salt.minion_pub = "test/keys/master_minion.pub"
      salt.install_type = "stable"
      salt.version = "3004.1"
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
    ["system.dev", "#{net_ip}.12", os_ram, os_u20],
    ["pve.dev", "#{net_ip}.13", os_ram, "debian/buster64"],
    ["web-vm.dev", "#{net_ip}.14", 8192, os_u20],
    ["backup.dev", "#{net_ip}.15", os_ram, os_u20],
    ["home.dev", "#{net_ip}.17", os_ram, os_u20],
    ["media.dev", "#{net_ip}.18", os_ram, os_u20],
    ["eu.petro.dev", "#{net_ip}.19", os_ram, os_d10],
    ["build-linux.dev", "#{net_ip}.20", os_ram, os_u20],
    ["metrics.dev", "#{net_ip}.21", os_ram, os_u20],
    ["rpi.office.dev", "#{net_ip}.22", os_ram, os_d11],
    ["ru.vds.dev", "#{net_ip}.23", os_ram, os_u20],
  ].each do |vmname, ip, mem, os|
    config.vm.define "#{vmname}" do |minion_config|
      minion_config.vm.provider "virtualbox" do |vb|
        vb.memory = "#{mem}"
        vb.cpus = cpu_count / 2
        vb.name = "#{vmname}"
      end

      minion_config.vbguest.auto_update = false
      minion_config.vm.box = "#{os}"
      minion_config.vm.hostname = "#{vmname}"
      minion_config.vm.network "private_network", ip: "#{ip}"

      # Do not update VBox additions (VBox only) - speedup of machine creation
      if Vagrant.has_plugin?("vagrant-vbguest")
        minion_config.vbguest.auto_update = false
      end

      if File.directory?(File.expand_path("test/srv/#{vmname}"))
        minion_config.vm.synced_folder "test/srv/#{vmname}", "/srv", type: "rsync", rsync__auto: false, rsync__chown: false, rsync__args: ['--verbose', '-r', '-z', '--copy-links']
      end

      minion_config.vm.provision :shell, run: "once", path: "test/set-dns.sh", args: net_dns_ip
      minion_config.vm.provision :shell, run: "once", path: "test/configure-minion.sh"

      minion_config.vm.provision :salt do |salt|
        salt.install_type = "stable"
        salt.version = "3004.1"
        salt.verbose = true
        salt.colorize = true
        salt.bootstrap_options = "-x python3 -P -c /tmp -A #{net_ip}.10 -i #{vmname}"
      end
    end
  end

  # ============================================================================================
  # Salt local test config

  config.vm.define "salt-local" do |local_config|
    local_config.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = cpu_count / 2
      vb.name = "local-salt"
    end

    local_config.vm.box = "#{os_u18}"
    local_config.vm.host_name = "salt-local.local"
    local_config.vm.network "private_network", ip: "#{net_ip}.11"
    local_config.vm.synced_folder ".", "/srv/salt"

    local_config.vm.provision :salt do |salt|
      salt.install_type = "stable"
      salt.version = "3001.1"
      salt.masterless = true
      salt.verbose = true
      salt.colorize = true
      salt.bootstrap_options = "-x python3 -P -c /tmp"
    end
  end
end
