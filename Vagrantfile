Vagrant.configure("2") do |config|
  
  # define variables containing servers ips 
  vault_server_ip = "192.168.2.10"
  web_server_ip = "192.168.2.20"
  
  # general VMs config
  config.vm.box = "slavrd/xenial64"
  config.vm.provision :shell, :path => "scripts/provision.sh"

  # define Vault server VM
  config.vm.define "vault01" do |v1|
      v1.vm.hostname = "vault01"
      v1.vm.network "private_network", ip: vault_server_ip
      v1.vm.network "forwarded_port", guest: 8200, host: 8200
      
      # set VM specs
      v1.vm.provider "virtualbox" do |v|
        v.memory = 1024
        v.cpus = 2
      end

      v1.vm.provision :shell, :path => "scripts/vault_setup.sh", run: "always"
      v1.vm.provision :shell, :path => "scripts/vault_setup_ca.sh", run: "always"
  end

  # define web server VM
  config.vm.define "web01" do |w1|

    w1.vm.box = "slavrd/nginx64"
    w1.vm.hostname = "web01"
    w1.vm.network "private_network", ip: web_server_ip
    w1.vm.network "forwarded_port", guest: 443, host: 4443

    w1.vm.provision "shell", run: "always" do |s|
      s.path = "scripts/vault_setup_client.sh"
      s.args = [vault_server_ip]
    end
  
  end

  # define web client VM
  config.vm.define "client01" do |c1|
    c1.vm.hostname = "client01"
    c1.vm.network "private_network", ip: "192.168.2.100"

    c1.vm.provision "shell" do |s|
      s.path = "scripts/web_client_setup.sh"
      s.args = [vault_server_ip,web_server_ip]
    end

  end

end
