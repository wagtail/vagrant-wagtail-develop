# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "torchbox/wagtail"
  config.vm.box_version = "~> 1.0"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In this case,
  # accessing "localhost:8000" will access port 8000 on the guest machine.
  config.vm.network "forwarded_port", guest: 8000, host: 8000

  # Share additional folders to the guest VM

  config.vm.synced_folder "./wagtail", "/home/vagrant/wagtail"
  config.vm.synced_folder "./wagtaildemo", "/home/vagrant/wagtaildemo"
  config.vm.synced_folder "./libs", "/home/vagrant/libs"

  # Provider-specific configuration for VirtualBox.
  config.vm.provider "virtualbox" do |vb|

    # Building node-sass requires more than the default 512Mb of memory
    vb.memory = 1024
  end

  # Enable provisioning with a shell script
  config.vm.provision :shell, :path => "vagrant/provision.sh"

  # Enable agent forwarding over SSH connections.
  config.ssh.forward_agent = true

  # If a 'Vagrantfile.local' file exists, import any configuration settings
  # defined there into here. Vagrantfile.local is ignored in version control,
  # so this can be used to add configuration specific to this computer.
  if File.exist? "Vagrantfile.local"
    instance_eval File.read("Vagrantfile.local"), "Vagrantfile.local"
  end
end
