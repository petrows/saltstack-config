# -*- mode: ruby -*-
# vi: set ft=ruby :

boxes = {
  'ubuntu/xenial64' => {
    'name'  => 'ubuntu/xenial64',
    'url'   => 'ubuntu/xenial64'
  },
}

Vagrant.configure("2") do |config|

  config.vm.define :cluster_config do |cluster_config|

    cluster_config.vm.hostname = 'config.cluster.local'
    cluster_config.vm.box = 'ubuntu/xenial64'
    cluster_config.vm.box_url = boxes['ubuntu/xenial64']['url']
    cluster_config.vm.network :private_network, ip: "10.10.10.200"

    cluster_config.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", 512]
      vb.customize ["modifyvm", :id, "--cpus", 1]
      vb.name = 'cluster-config'
      vb.gui = false
    end

    cluster_config.vm.provision :salt do |salt|
      salt.minion_config = "minions/config.conf"
      salt.colorize = true
      salt.bootstrap_options = "-F -c /tmp -P"
    end
  
  end

  config.vm.define :cluster_service do |cluster_service|

    cluster_service.vm.hostname = 'service.cluster.local'
    cluster_service.vm.box = 'ubuntu/xenial64'
    cluster_service.vm.box_url = boxes['ubuntu/xenial64']['url']
    cluster_service.vm.network :private_network, ip: "10.10.10.201"

    cluster_service.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", 4096]
      vb.customize ["modifyvm", :id, "--cpus", 1]
      vb.name = 'cluster-servie'
      vb.gui = false
    end

    cluster_service.vm.provision :salt do |salt|
      salt.minion_config = "minions/service.conf"
      salt.colorize = true
      salt.bootstrap_options = "-F -c /tmp -P"
    end
  
  end

end

