required_plugins = [
  "vagrant-compose",
  "vagrant-hostmanager",
  "vagrant-timezone"
]

Vagrant.configure(2) do |config|
  config.ssh.insert_key = false
  config.timezone.value = :host

  required_plugins.each do |plugin|
    if not Vagrant.has_plugin?(plugin)
      raise "Install required plugin: #{plugin} `vagrant plugin install #{plugin}`"
    end
  end

  config.cluster.compose('pacemaker') do |c|
    c.nodes(3, 'ha') do |n|
      n.memory = "256"
      n.box = "bento/ubuntu-14.04"
      n.ansible_groups = ['pacemaker-nodes']
    end
  end

  # Global scope provisioner - runs first
  config.vm.provision "fix-no-tty", type: "shell" do |s|
    s.privileged = false
    s.inline = "sudo sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /root/.profile"
  end
  config.vm.provision "shell", inline: $provision_shell_script

  config.cluster.nodes.each do |node|
    config.vm.define "#{node.boxname}" do |node_config|
      node_config.vm.box = "#{node.box}"
      node_config.vm.hostname = "#{node.boxname}"
      node_config.vm.network 'private_network', type: "dhcp"

      node_config.vm.provider :virtualbox do |vb|
        vb.memory = node.memory
        vb.cpus = node.cpus
        vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        vb.customize ['guestproperty', 'set', :id, '/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold', 10000]
      end

      node_config.vm.provider "vmware_fusion" do |vb|
        vb.vmx["memsize"] = node.memory
        vb.vmx["numvcpus"] = node.cpus
      end

      # Only run ansible provisioner after all nodes are up
      if node.index == config.cluster.nodes.size - 1
        node_config.vm.provision "ansible" do |ansible|
          ansible.playbook = "tests/vagrant.yml"
          ansible.extra_vars = "tests/vars.yml"
          ansible.limit = "all"
          ansible.groups = config.cluster.ansible_groups
          ansible.sudo = true
          ansible.verbose = true
        end
      end
    end
  end

end

$provision_shell_script = <<SCRIPT
echo "Updating apt cache"
apt-get -qy update >/dev/null 2>&1
SCRIPT
