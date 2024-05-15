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
  os_u22 = "bento/ubuntu-22.04"
  os_u24 = "bento/ubuntu-24.04"
  os_d10 = "debian/buster64"
  os_d11 = "debian/bullseye64"
  os_ram = 2048
  net_ip = "10.99.99"
  net_dns_ip = "10.99.99.1,10.99.99.254"

  config.ssh.username = 'vagrant'
  config.ssh.password = 'vagrant'

  # ============================================================================================
  # Salt master config

  config.vm.define :master, primary: true do |master_config|
    master_config.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = cpu_count / 2
      vb.name = "master"
    end

    master_config.vm.box = "#{os_u24}"
    master_config.vm.host_name = "saltmaster.local"
    master_config.vm.network "private_network", ip: "#{net_ip}.10"
    master_config.vm.synced_folder "saltstack/salt/", "/vg/salt"
    master_config.vm.synced_folder "saltstack/pillar/", "/vg/pillar"
    master_config.vm.synced_folder "test", "/vg/test"
    if FileTest::directory?("secrets/")
      master_config.vm.synced_folder "secrets/", "/vg/secrets"
    end

    # master_config.vm.provision :shell, run: "once", path: "test/set-dns.sh", args: net_dns_ip
    master_config.vm.provision :shell, run: "once", path: "test/setup-salt.sh", args: "master"
    master_config.vm.provision :shell, run: "once", path: "test/configure-master.sh"

    # We need to update guest package on master VM, otherwise it wont work correctly
    # File mtime may be exposed uncorrectly and this will break salt-master fs watch
    if Vagrant.has_plugin?("vagrant-vbguest")
      master_config.vbguest.auto_update = true
    end
  end

  # ============================================================================================
  # Salt minion config

  [
    ["system.dev", "#{net_ip}.12", os_ram, os_u24],
    ["pve.dev", "#{net_ip}.13", os_ram, "debian/buster64"],
    ["web-vm.dev", "#{net_ip}.14", 8192, os_u24],
  ].each do |vmname, ip, mem, os|
    config.vm.define "#{vmname}" do |minion_config|
      minion_config.vm.provider "virtualbox" do |vb|
        vb.memory = "#{mem}"
        vb.cpus = cpu_count / 2
        vb.name = "#{vmname}"
      end

      minion_config.vm.box = "#{os}"
      minion_config.vm.hostname = "#{vmname}"
      minion_config.vm.network "private_network", ip: "#{ip}"

      minion_config.vm.provider :virtualbox do |vb|
        vb.customize [
          'modifyvm', :id,
          '--hpet', 'on'
        ]
      end

      # Do not update VBox additions (VBox only) - speedup of machine creation
      if Vagrant.has_plugin?("vagrant-vbguest")
        minion_config.vbguest.auto_update = false
      end

      if File.directory?(File.expand_path("test/srv/#{vmname}"))
        minion_config.vm.synced_folder "test/srv/#{vmname}", "/srv", type: "rsync", rsync__auto: false, rsync__chown: false, rsync__args: ['--verbose', '-r', '-z', '--copy-links']
      end

      minion_config.vm.provision :shell, run: "once", path: "test/set-dns.sh", args: net_dns_ip
      minion_config.vm.provision :shell, run: "once", path: "test/setup-salt.sh", args: "minion"
      minion_config.vm.provision :shell, run: "once", path: "test/configure-minion.sh", args: ["#{net_ip}.10", "#{vmname}"]

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
      salt.version = "3006"
      salt.masterless = true
      salt.verbose = true
      salt.colorize = true
      salt.bootstrap_options = "-x python3 -P -c /tmp"
    end
  end
end
