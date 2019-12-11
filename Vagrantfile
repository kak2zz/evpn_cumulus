$script = <<-SCRIPT
if grep -q -i 'cumulus' /etc/lsb-release &> /dev/null; then
    echo "### RUNNING CUMULUS EXTRA CONFIG ###"
    source /etc/lsb-release
    if [[ $DISTRIB_RELEASE =~ ^2.* ]]; then
        echo "  INFO: Detected a 2.5.x Based Release"
        echo "  adding fake cl-acltool..."
        echo -e "#!/bin/bash\nexit 0" > /usr/bin/cl-acltool
        chmod 755 /usr/bin/cl-acltool
        echo "  adding fake cl-license..."
        echo -e "#!/bin/bash\nexit 0" > /usr/bin/cl-license
        chmod 755 /usr/bin/cl-license
        echo "  Disabling default remap on Cumulus VX..."
        mv -v /etc/init.d/rename_eth_swp /etc/init.d/rename_eth_swp.backup
        echo "### Rebooting to Apply Remap..."
        reboot
    elif [[ $DISTRIB_RELEASE =~ ^3.* ]]; then
        echo "  INFO: Detected a 3.x Based Release"
        echo "  Disabling default remap on Cumulus VX..."
        mv -v /etc/hw_init.d/S10rename_eth_swp.sh /etc/S10rename_eth_swp.sh.backup
        #echo "### Applying Remap without Reboot..."
        #~/apply_udev.py --apply
        #echo "### Performing IFRELOAD to Apply any Latent Interface Config..."
        #ifreload -a 2>&1
        echo "### Disabling ZTP service..."
        systemctl stop ztp.service
        ztp -d 2>&1
        echo "### Resetting ZTP to work next boot..."
        ztp -R 2>&1
        echo "### Rebooting Switch to Apply Remap..."
        reboot
    fi
    echo "### DONE ###"
else
    echo "### Rebooting to Apply Remap..."
    reboot
fi
SCRIPT

##
VAGRANTFILE_API_VERSION = "2"


Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    ##### DEFINE VM for manage #####
    config.vm.define "manage" do |device|
      device.vm.box = "ubuntu/xenial64"
      device.vm.provider "virtualbox" do |v|
        v.name = "manage"
        v.memory = 512
      end
      device.ssh.forward_agent = true
      device.vm.synced_folder ".", "/vagrant", disabled: true
      device.vm.network "private_network", :name => 'vboxnet0', :mac => "aaaaaaaa1111", auto_config: false, ip: "172.16.5.100"

      #host configuration
      device.vm.provision :shell , privileged: true, :inline => 'echo manage > /etc/hostname'
      device.vm.provision :shell , privileged: true, :inline => 'hostname manage'
      device.vm.provision :shell , privileged: true, :inline => 'echo 127.0.0.1  manage >> /etc/hosts'
      device.vm.provision :shell , privileged: true, :inline => 'echo -e "172.16.5.11 dc1server\n172.16.5.12 dc2server\n172.16.5.13 dc3server\n172.16.5.14 dc1sw1\n172.16.5.15 dc1sw2\n172.16.5.16 dc2sw1\n172.16.5.17 dc2sw2\n172.16.5.18 dc3sw1\n172.16.5.19 dc3sw2" >> /etc/hosts'
      #interfaces configuration
      device.vm.provision :shell , privileged: true, :inline => 'sudo ip link set up enp0s8'
      device.vm.provision :shell , privileged: true, :inline => 'sudo ip add add 172.16.5.100/24 dev enp0s8' 

      device.vm.provision :shell , privileged: true, :inline => 'sudo apt -y update; sudo apt-get install -y isc-dhcp-server'
      device.vm.provision :shell , privileged: true, :inline => 'echo -e "subnet 172.16.5.0 netmask 255.255.255.0 {\n   range 172.16.5.10 172.16.5.90;\n   option domain-name-servers 172.16.5.100;\n   option routers 172.16.5.100;\n   default-lease-time 600;\n   max-lease-time 7200;\n   \n}\nhost dc1server {\n    hardware ethernet AA:AA:AA:A1:11:11; fixed-address 172.16.5.11;\n}\nhost dc2server {\n    hardware ethernet AA:AA:AA:A1:11:12; fixed-address 172.16.5.12;\n}\nhost dc3server {\n    hardware ethernet AA:AA:AA:A1:11:13; fixed-address 172.16.5.13;\n}\nhost dc1sw1 {\n    hardware ethernet AA:AA:AA:A1:11:14; fixed-address 172.16.5.14;\n}\nhost dc1sw2 {\n    hardware ethernet AA:AA:AA:A1:11:15; fixed-address 172.16.5.15;\n}\nhost dc2sw1 {\n    hardware ethernet AA:AA:AA:A1:11:16; fixed-address 172.16.5.16;\n}\nhost dc2sw2 {\n    hardware ethernet AA:AA:AA:A1:11:17; fixed-address 172.16.5.17;\n}\nhost dc3sw1 {\n    hardware ethernet AA:AA:AA:A1:11:18; fixed-address 172.16.5.18;\n}\nhost dc3sw2 {\n    hardware ethernet AA:AA:AA:A1:11:19; fixed-address 172.16.5.19;\n}\n" > /etc/dhcp/dhcpd.conf'
      device.vm.provision :shell , privileged: true, :inline => 'service isc-dhcp-server restart'
      device.vm.provision :shell , path: "./helper_scripts/config_manage_server.sh"
    end



    ############################################################
    ##### DEFINE cumulus SWITCHES ##############################
    ############################################################

    ##### DEFINE dc1sw1 #####
    config.vm.define "dc1sw1" do |device|
      device.vm.box = "CumulusCommunity/cumulus-vx"
  	  config.vm.box_version = "3.7"
      device.vm.provider "virtualbox" do |v|
        v.name = "dc1sw1"
        v.memory = 512
      end
      device.vm.synced_folder ".", "/vagrant", disabled: true
      device.ssh.host = '172.16.5.14'
    
      # NETWORK INTERFACES
      # NETWORK INTERFACES
      #manage interface
      device.vm.network "private_network", :name => 'vboxnet0', :mac => "aaaaaaa11114", :adapter => 1, auto_config: false, ip: "172.16.5.14"

  	  #swp1
      device.vm.network "private_network", virtualbox__intnet: "1", auto_config: false , :mac => "aaaaaaaa1101"
  	  #swp2
      device.vm.network "private_network", virtualbox__intnet: "2", auto_config: false , :mac => "aaaaaaaa1102"
  	  #swp3
      device.vm.network "private_network", virtualbox__intnet: "5", auto_config: false , :mac => "aaaaaaaa1103"
  	  #swp4
      device.vm.network "private_network", virtualbox__intnet: "6", auto_config: false , :mac => "aaaaaaaa1104"
  	  #swp5
      device.vm.network "private_network", virtualbox__intnet: "19", auto_config: false , :mac => "aaaaaaaa1105"
  	  #swp6
      device.vm.network "private_network", virtualbox__intnet: "20", auto_config: false , :mac => "aaaaaaaa1106"
  	  #swp7
      device.vm.network "private_network", virtualbox__intnet: "13", auto_config: false , :mac => "aaaaaaaa1107"

      device.vm.provider "virtualbox" do |vbox|
        vbox.customize ['modifyvm', :id, '--nicpromisc2', 'allow-all']
        vbox.customize ['modifyvm', :id, '--nicpromisc3', 'allow-all']
        vbox.customize ['modifyvm', :id, '--nicpromisc4', 'allow-all']
        vbox.customize ['modifyvm', :id, '--nicpromisc5', 'allow-all']
        vbox.customize ['modifyvm', :id, '--nicpromisc6', 'allow-all']
        vbox.customize ['modifyvm', :id, '--nicpromisc7', 'allow-all']
        vbox.customize ['modifyvm', :id, '--nicpromisc8', 'allow-all']
        vbox.customize ["modifyvm", :id, "--nictype1", "virtio"]
      end


      # Copy over configuration files
      device.vm.provision "file", source: "./config/dc1sw1/interfaces", destination: "~/interfaces"
      device.vm.provision "file", source: "./config/dc1sw1/daemons", destination: "~/daemons"
      device.vm.provision "file", source: "./config/dc1sw1/frr.conf", destination: "~/frr.conf"
      
      device.vm.provision :shell , privileged: true, :inline => 'echo dc1sw1 > /etc/hostname'
      device.vm.provision :shell , privileged: true, :inline => 'echo 127.0.0.1    dc1sw1 >> /etc/hosts'
      device.vm.provision :shell , privileged: true, :inline => 'rm -rf /etc/udev/rules.d/*'
      device.vm.provision :shell , path: "./helper_scripts/config_switch.sh"



       device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:11:01 --> swp1"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="aa:aa:aa:aa:11:01", NAME="swp1", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule
       device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:11:02 --> swp2"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="aa:aa:aa:aa:11:02", NAME="swp2", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule
       device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:11:03 --> swp3"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="aa:aa:aa:aa:11:03", NAME="swp3", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule
       device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:11:04 --> swp4"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="aa:aa:aa:aa:11:04", NAME="swp4", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule
       device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:11:05 --> swp5"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="aa:aa:aa:aa:11:05", NAME="swp5", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule
       device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:11:06 --> swp6"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="aa:aa:aa:aa:11:06", NAME="swp6", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule
       device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:11:07 --> swp7"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="aa:aa:aa:aa:11:07", NAME="swp7", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule



      device.vm.provision :shell , :inline => $script

  end



    ##### DEFINE dc1sw2 #####
    config.vm.define "dc1sw2" do |device|
      device.vm.box = "CumulusCommunity/cumulus-vx"
      device.vm.box_version = "3.7"
      device.vm.provider "virtualbox" do |v|
        v.name = "dc1sw2"
        v.memory = 512
      end
      device.vm.synced_folder ".", "/vagrant", disabled: true
      device.ssh.host = '172.16.5.15'

      # NETWORK INTERFACES
      #manage interface
      device.vm.network "private_network", :name => 'vboxnet0', :mac => "aaaaaaa11115", :adapter => 1, auto_config: false, ip: "172.16.5.15"

  	  #swp1
      device.vm.network "private_network", virtualbox__intnet: "3", auto_config: false , :mac => "aaaaaaaa1201"
  	  #swp2
      device.vm.network "private_network", virtualbox__intnet: "4", auto_config: false , :mac => "aaaaaaaa1202"
  	  #swp3
      device.vm.network "private_network", virtualbox__intnet: "7", auto_config: false , :mac => "aaaaaaaa1203"
  	  #swp4
      device.vm.network "private_network", virtualbox__intnet: "8", auto_config: false , :mac => "aaaaaaaa1204"
  	  #swp5
      device.vm.network "private_network", virtualbox__intnet: "19", auto_config: false , :mac => "aaaaaaaa1205"
  	  #swp6
      device.vm.network "private_network", virtualbox__intnet: "20", auto_config: false , :mac => "aaaaaaaa1206"
  	  #swp7
      device.vm.network "private_network", virtualbox__intnet: "14", auto_config: false , :mac => "aaaaaaaa1207"
      
      device.vm.provider "virtualbox" do |vbox|
        vbox.customize ['modifyvm', :id, '--nicpromisc2', 'allow-all']
        vbox.customize ['modifyvm', :id, '--nicpromisc3', 'allow-all']
        vbox.customize ['modifyvm', :id, '--nicpromisc4', 'allow-all']
        vbox.customize ['modifyvm', :id, '--nicpromisc5', 'allow-all']
        vbox.customize ['modifyvm', :id, '--nicpromisc6', 'allow-all']
        vbox.customize ['modifyvm', :id, '--nicpromisc7', 'allow-all']
        vbox.customize ['modifyvm', :id, '--nicpromisc8', 'allow-all']
        vbox.customize ["modifyvm", :id, "--nictype1", "virtio"]
      end

      # Copy over configuration files
      device.vm.provision "file", source: "./config/dc1sw2/interfaces", destination: "~/interfaces"
      device.vm.provision "file", source: "./config/dc1sw2/daemons", destination: "~/daemons"
      device.vm.provision "file", source: "./config/dc1sw2/frr.conf", destination: "~/frr.conf"
      
      device.vm.provision :shell , privileged: true, :inline => 'echo dc1sw2 > /etc/hostname'
      device.vm.provision :shell , privileged: true, :inline => 'echo 127.0.0.1    dc1sw2 >> /etc/hosts'
      device.vm.provision :shell , privileged: true, :inline => 'rm -rf /etc/udev/rules.d/*'
      device.vm.provision :shell , path: "./helper_scripts/config_switch.sh"



       device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:12:01 --> swp1"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="aa:aa:aa:aa:12:01", NAME="swp1", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule
       device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:12:02 --> swp2"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="aa:aa:aa:aa:12:02", NAME="swp2", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule
       device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:12:03 --> swp3"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="aa:aa:aa:aa:12:03", NAME="swp3", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule
       device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:12:04 --> swp4"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="aa:aa:aa:aa:12:04", NAME="swp4", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule
       device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:12:05 --> swp5"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="aa:aa:aa:aa:12:05", NAME="swp5", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule
       device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:12:06 --> swp6"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="aa:aa:aa:aa:12:06", NAME="swp6", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule
       device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:12:07 --> swp7"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="aa:aa:aa:aa:12:07", NAME="swp7", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule

      device.vm.provision :shell , :inline => $script

  end





    ##### DEFINE dc2sw1 #####
    config.vm.define "dc2sw1" do |device|
      device.vm.box = "CumulusCommunity/cumulus-vx"
      device.vm.box_version = "3.7"
      device.vm.provider "virtualbox" do |v|
        v.name = "dc2sw1"
        v.memory = 512
      end
      device.vm.synced_folder ".", "/vagrant", disabled: true
      device.ssh.host = '172.16.5.16'
    
      # NETWORK INTERFACES

      #manage interface
      device.vm.network "private_network", :name => 'vboxnet0', :mac => "aaaaaaa11116", :adapter => 1, auto_config: false, ip: "172.16.5.16"

  	  #swp1
      device.vm.network "private_network", virtualbox__intnet: "1", auto_config: false , :mac => "aaaaaaaa2101"
  	  #swp2
      device.vm.network "private_network", virtualbox__intnet: "3", auto_config: false , :mac => "aaaaaaaa2102"
  	  #swp3
      device.vm.network "private_network", virtualbox__intnet: "9", auto_config: false , :mac => "aaaaaaaa2103"
  	  #swp4
      device.vm.network "private_network", virtualbox__intnet: "11", auto_config: false , :mac => "aaaaaaaa2104"
  	  #swp5
      device.vm.network "private_network", virtualbox__intnet: "23", auto_config: false , :mac => "aaaaaaaa2105"
  	  #swp6
      device.vm.network "private_network", virtualbox__intnet: "24", auto_config: false , :mac => "aaaaaaaa2106"
  	  #swp7
      device.vm.network "private_network", virtualbox__intnet: "15", auto_config: false , :mac => "aaaaaaaa2107"
      

      device.vm.provider "virtualbox" do |vbox|
        vbox.customize ['modifyvm', :id, '--nicpromisc2', 'allow-all']
        vbox.customize ['modifyvm', :id, '--nicpromisc3', 'allow-all']
        vbox.customize ['modifyvm', :id, '--nicpromisc4', 'allow-all']
        vbox.customize ['modifyvm', :id, '--nicpromisc5', 'allow-all']
        vbox.customize ['modifyvm', :id, '--nicpromisc6', 'allow-all']
        vbox.customize ['modifyvm', :id, '--nicpromisc7', 'allow-all']
        vbox.customize ['modifyvm', :id, '--nicpromisc8', 'allow-all']
        vbox.customize ["modifyvm", :id, "--nictype1", "virtio"]
      end



      # Copy over configuration files
      device.vm.provision "file", source: "./config/dc2sw1/interfaces", destination: "~/interfaces"
      device.vm.provision "file", source: "./config/dc2sw1/daemons", destination: "~/daemons"
      device.vm.provision "file", source: "./config/dc2sw1/frr.conf", destination: "~/frr.conf"
      
      device.vm.provision :shell , privileged: true, :inline => 'echo dc2sw1 > /etc/hostname'
      device.vm.provision :shell , privileged: true, :inline => 'echo 127.0.0.1    dc2sw1 >> /etc/hosts'
      device.vm.provision :shell , privileged: true, :inline => 'rm -rf /etc/udev/rules.d/*'

      device.vm.provision :shell , path: "./helper_scripts/config_switch.sh"



       device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:21:01 --> swp1"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="aa:aa:aa:aa:21:01", NAME="swp1", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule
       device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:21:02 --> swp2"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="aa:aa:aa:aa:21:02", NAME="swp2", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule
       device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:21:03 --> swp3"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="aa:aa:aa:aa:21:03", NAME="swp3", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule
       device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:21:04 --> swp4"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="aa:aa:aa:aa:21:04", NAME="swp4", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule
       device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:21:05 --> swp5"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="aa:aa:aa:aa:21:05", NAME="swp5", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule
       device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:21:06 --> swp6"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="aa:aa:aa:aa:21:06", NAME="swp6", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule
       device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:21:07 --> swp7"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="aa:aa:aa:aa:21:07", NAME="swp7", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule



      device.vm.provision :shell , :inline => $script

  end




   ##### DEFINE dc2sw2 #####
    config.vm.define "dc2sw2" do |device|
      device.vm.box = "CumulusCommunity/cumulus-vx"
      device.vm.box_version = "3.7"
      device.vm.provider "virtualbox" do |v|
        v.name = "dc2sw2"
        v.memory = 512
      end
      device.vm.synced_folder ".", "/vagrant", disabled: true
      device.ssh.host = '172.16.5.17'
    
      # NETWORK INTERFACES
      #manage interface
      device.vm.network "private_network", :name => 'vboxnet0', :mac => "aaaaaaa11117", :adapter => 1, auto_config: false, ip: "172.16.5.17"

  	  #swp1
      device.vm.network "private_network", virtualbox__intnet: "2", auto_config: false , :mac => "aaaaaaaa2201"
    	#swp2
      device.vm.network "private_network", virtualbox__intnet: "4", auto_config: false , :mac => "aaaaaaaa2202"
    	#swp3
      device.vm.network "private_network", virtualbox__intnet: "10", auto_config: false , :mac => "aaaaaaaa2203"
  	  #swp4
      device.vm.network "private_network", virtualbox__intnet: "12", auto_config: false , :mac => "aaaaaaaa2204"
  	  #swp5
      device.vm.network "private_network", virtualbox__intnet: "23", auto_config: false , :mac => "aaaaaaaa2205"
  	  #swp6
      device.vm.network "private_network", virtualbox__intnet: "24", auto_config: false , :mac => "aaaaaaaa2206"
  	  #swp7
      device.vm.network "private_network", virtualbox__intnet: "16", auto_config: false , :mac => "aaaaaaaa2207"
      
      device.vm.provider "virtualbox" do |vbox|
        vbox.customize ['modifyvm', :id, '--nicpromisc2', 'allow-all']
        vbox.customize ['modifyvm', :id, '--nicpromisc3', 'allow-all']
        vbox.customize ['modifyvm', :id, '--nicpromisc4', 'allow-all']
        vbox.customize ['modifyvm', :id, '--nicpromisc5', 'allow-all']
        vbox.customize ['modifyvm', :id, '--nicpromisc6', 'allow-all']
        vbox.customize ['modifyvm', :id, '--nicpromisc7', 'allow-all']
        vbox.customize ['modifyvm', :id, '--nicpromisc8', 'allow-all']
        vbox.customize ["modifyvm", :id, "--nictype1", "virtio"]
      end


      # Copy over configuration files
      device.vm.provision "file", source: "./config/dc2sw2/interfaces", destination: "~/interfaces"
      device.vm.provision "file", source: "./config/dc2sw2/daemons", destination: "~/daemons"
      device.vm.provision "file", source: "./config/dc2sw2/frr.conf", destination: "~/frr.conf"
      
      device.vm.provision :shell , privileged: true, :inline => 'echo dc2sw2 > /etc/hostname'
      device.vm.provision :shell , privileged: true, :inline => 'echo 127.0.0.1    dc2sw2 >> /etc/hosts'
      device.vm.provision :shell , privileged: true, :inline => 'rm -rf /etc/udev/rules.d/*'

      device.vm.provision :shell , path: "./helper_scripts/config_switch.sh"



       device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:22:01 --> swp1"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="aa:aa:aa:aa:22:01", NAME="swp1", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule
       device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:22:02 --> swp2"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="aa:aa:aa:aa:22:02", NAME="swp2", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule
       device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:22:03 --> swp3"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="aa:aa:aa:aa:22:03", NAME="swp3", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule
       device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:22:04 --> swp4"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="aa:aa:aa:aa:22:04", NAME="swp4", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule
       device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:22:05 --> swp5"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="aa:aa:aa:aa:22:05", NAME="swp5", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule
       device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:22:06 --> swp6"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="aa:aa:aa:aa:22:06", NAME="swp6", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule
       device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:22:07 --> swp7"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="aa:aa:aa:aa:22:07", NAME="swp7", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule


      device.vm.provision :shell , :inline => $script

  end



   ##### DEFINE dc3sw1 #####
    config.vm.define "dc3sw1" do |device|
      device.vm.box = "CumulusCommunity/cumulus-vx"
      device.vm.box_version = "3.7"
      device.vm.provider "virtualbox" do |v|
        v.name = "dc3sw1"
        v.memory = 512
      end
      device.vm.synced_folder ".", "/vagrant", disabled: true
      device.ssh.host = '172.16.5.18'
    
      # NETWORK INTERFACES
      #manage interface
      device.vm.network "private_network", :name => 'vboxnet0', :mac => "aaaaaaa11118", :adapter => 1, auto_config: false, ip: "172.16.5.18"

  	  #swp1
      device.vm.network "private_network", virtualbox__intnet: "7", auto_config: false , :mac => "aaaaaaaa3101"
  	  #swp2
      device.vm.network "private_network", virtualbox__intnet: "5", auto_config: false , :mac => "aaaaaaaa3102"
  	  #swp3
      device.vm.network "private_network", virtualbox__intnet: "9", auto_config: false , :mac => "aaaaaaaa3103"
  	  #swp4
      device.vm.network "private_network", virtualbox__intnet: "10", auto_config: false , :mac => "aaaaaaaa3104"
  	  #swp5
      device.vm.network "private_network", virtualbox__intnet: "21", auto_config: false , :mac => "aaaaaaaa3105"
  	  #swp6
      device.vm.network "private_network", virtualbox__intnet: "22", auto_config: false , :mac => "aaaaaaaa3106"
  	  #swp7
      device.vm.network "private_network", virtualbox__intnet: "17", auto_config: false , :mac => "aaaaaaaa3107"
      
      device.vm.provider "virtualbox" do |vbox|
        vbox.customize ['modifyvm', :id, '--nicpromisc2', 'allow-all']
        vbox.customize ['modifyvm', :id, '--nicpromisc3', 'allow-all']
        vbox.customize ['modifyvm', :id, '--nicpromisc4', 'allow-all']
        vbox.customize ['modifyvm', :id, '--nicpromisc5', 'allow-all']
        vbox.customize ['modifyvm', :id, '--nicpromisc6', 'allow-all']
        vbox.customize ['modifyvm', :id, '--nicpromisc7', 'allow-all']
        vbox.customize ['modifyvm', :id, '--nicpromisc8', 'allow-all']
        vbox.customize ["modifyvm", :id, "--nictype1", "virtio"]
      end


      # Copy over configuration files
      device.vm.provision "file", source: "./config/dc3sw1/interfaces", destination: "~/interfaces"
      device.vm.provision "file", source: "./config/dc3sw1/daemons", destination: "~/daemons"
      device.vm.provision "file", source: "./config/dc3sw1/frr.conf", destination: "~/frr.conf"
      
      device.vm.provision :shell , privileged: true, :inline => 'echo dc3sw1 > /etc/hostname'
      device.vm.provision :shell , privileged: true, :inline => 'echo 127.0.0.1    dc3sw1 >> /etc/hosts'
      device.vm.provision :shell , privileged: true, :inline => 'rm -rf /etc/udev/rules.d/*'

      device.vm.provision :shell , path: "./helper_scripts/config_switch.sh"



       device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:31:01 --> swp1"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="aa:aa:aa:aa:31:01", NAME="swp1", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule
       device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:31:02 --> swp2"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="aa:aa:aa:aa:31:02", NAME="swp2", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule
       device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:31:03 --> swp3"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="aa:aa:aa:aa:31:03", NAME="swp3", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule
       device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:31:04 --> swp4"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="aa:aa:aa:aa:31:04", NAME="swp4", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule
       device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:31:05 --> swp5"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="aa:aa:aa:aa:31:05", NAME="swp5", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule
       device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:31:06 --> swp6"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="aa:aa:aa:aa:31:06", NAME="swp6", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule
       device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:31:07 --> swp7"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="aa:aa:aa:aa:31:07", NAME="swp7", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule

      device.vm.provision :shell , :inline => $script

  end





   ##### DEFINE dc3sw2 #####
    config.vm.define "dc3sw2" do |device|
      device.vm.box = "CumulusCommunity/cumulus-vx"
      device.vm.box_version = "3.7"
      device.vm.provider "virtualbox" do |v|
        v.name = "dc3sw2"
        v.memory = 512
      end
      device.vm.synced_folder ".", "/vagrant", disabled: true
      device.ssh.host = '172.16.5.19'
    
      # NETWORK INTERFACES
      #manage interface
      device.vm.network "private_network", :name => 'vboxnet0', :mac => "aaaaaaa11119", :adapter => 1, auto_config: false, ip: "172.16.5.19"
 
  	  #swp1
      device.vm.network "private_network", virtualbox__intnet: "8", auto_config: false , :mac => "aaaaaaaa3201"
  	  #swp2
      device.vm.network "private_network", virtualbox__intnet: "6", auto_config: false , :mac => "aaaaaaaa3202"
  	  #swp3
      device.vm.network "private_network", virtualbox__intnet: "11", auto_config: false , :mac => "aaaaaaaa3203"
  	  #swp4
      device.vm.network "private_network", virtualbox__intnet: "12", auto_config: false , :mac => "aaaaaaaa3204"
  	  #swp5
      device.vm.network "private_network", virtualbox__intnet: "21", auto_config: false , :mac => "aaaaaaaa3205"
  	  #swp6
      device.vm.network "private_network", virtualbox__intnet: "22", auto_config: false , :mac => "aaaaaaaa3206"
  	  #swp7
      device.vm.network "private_network", virtualbox__intnet: "18", auto_config: false , :mac => "aaaaaaaa3207"
      
      device.vm.provider "virtualbox" do |vbox|
        vbox.customize ['modifyvm', :id, '--nicpromisc2', 'allow-all']
        vbox.customize ['modifyvm', :id, '--nicpromisc3', 'allow-all']
        vbox.customize ['modifyvm', :id, '--nicpromisc4', 'allow-all']
        vbox.customize ['modifyvm', :id, '--nicpromisc5', 'allow-all']
        vbox.customize ['modifyvm', :id, '--nicpromisc6', 'allow-all']
        vbox.customize ['modifyvm', :id, '--nicpromisc7', 'allow-all']
        vbox.customize ['modifyvm', :id, '--nicpromisc8', 'allow-all']
        vbox.customize ["modifyvm", :id, "--nictype1", "virtio"]
      end


      # Copy over configuration files
      device.vm.provision "file", source: "./config/dc3sw2/interfaces", destination: "~/interfaces"
      device.vm.provision "file", source: "./config/dc3sw2/daemons", destination: "~/daemons"
      device.vm.provision "file", source: "./config/dc3sw2/frr.conf", destination: "~/frr.conf"
      
      device.vm.provision :shell , privileged: true, :inline => 'echo dc3sw2 > /etc/hostname'
      device.vm.provision :shell , privileged: true, :inline => 'echo 127.0.0.1    dc3sw2 >> /etc/hosts'
      device.vm.provision :shell , privileged: true, :inline => 'rm -rf /etc/udev/rules.d/*'

      device.vm.provision :shell , path: "./helper_scripts/config_switch.sh"



       device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:32:01 --> swp1"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="aa:aa:aa:aa:32:01", NAME="swp1", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule
       device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:32:02 --> swp2"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="aa:aa:aa:aa:32:02", NAME="swp2", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule
       device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:32:03 --> swp3"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="aa:aa:aa:aa:32:03", NAME="swp3", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule
       device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:32:04 --> swp4"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="aa:aa:aa:aa:32:04", NAME="swp4", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule
       device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:32:05 --> swp5"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="aa:aa:aa:aa:32:05", NAME="swp5", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule
       device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:32:06 --> swp6"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="aa:aa:aa:aa:32:06", NAME="swp6", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule
       device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:32:07 --> swp7"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="aa:aa:aa:aa:32:07", NAME="swp7", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule

      device.vm.provision :shell , :inline => $script

  end







    ##### DEFINE VM for dc1server #####
    config.vm.define "dc1server" do |device|
      device.vm.box = "CumulusCommunity/cumulus-vx"
      device.vm.box_version = "3.7"
      device.vm.provider "virtualbox" do |v|
        v.name = "dc1server"
        v.memory = 512
      end

      device.vm.synced_folder ".", "/vagrant", disabled: true
      device.ssh.host = '172.16.5.11'


      # NETWORK INTERFACES
      # NETWORK INTERFACES
      #manage interface
      device.vm.network "private_network", :name => 'vboxnet0', :mac => "aaaaaaa11111", :adapter => 1, auto_config: false, ip: "172.16.5.11"

        #eth1
        device.vm.network "private_network", virtualbox__intnet: "13", auto_config: false , :mac => "aaaaaaaa0101"

        #eth2
        device.vm.network "private_network", virtualbox__intnet: "14", auto_config: false , :mac => "aaaaaaaa0102"


      device.vm.provider "virtualbox" do |vbox|
        vbox.customize ['modifyvm', :id, '--nicpromisc2', 'allow-all']
        vbox.customize ['modifyvm', :id, '--nicpromisc3', 'allow-all']
        vbox.customize ["modifyvm", :id, "--nictype1", "virtio"]
      end

      # Copy over configuration files

      device.vm.provision "file", source: "./config/dc1server/interfaces", destination: "~/interfaces"
      device.vm.provision "file", source: "./helper_scripts/dc1server.sh", destination: "~/dc1server.sh"
      device.vm.provision :shell , privileged: true, :inline => 'chmod +x /home/vagrant/dc1server.sh'
      device.vm.provision :shell , path: "./helper_scripts/config_server.sh"
      

      device.vm.provision :shell , privileged: true, :inline => 'echo dc1server > /etc/hostname'
      device.vm.provision :shell , privileged: true, :inline => 'echo 127.0.0.1    dc1server >> /etc/hosts'
      device.vm.provision :shell , privileged: true, :inline => 'rm -rf /etc/udev/rules.d/*'

      device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:01:01 --> eth1"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="aa:aa:aa:aa:01:01", NAME="eth1", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule
       device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:01:02 --> eth2"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="4aa:aa:aa:aa:01:02", NAME="eth2", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule


      device.vm.provision :shell , :inline => $script

  end




    ##### DEFINE VM for dc2server #####
    config.vm.define "dc2server" do |device|
      device.vm.box = "CumulusCommunity/cumulus-vx"
      device.vm.box_version = "3.7"
      device.vm.provider "virtualbox" do |v|
        v.name = "dc2server"
        v.memory = 512
      end

      device.vm.synced_folder ".", "/vagrant", disabled: true
      device.ssh.host = '172.16.5.12'


      # NETWORK INTERFACES
      # NETWORK INTERFACES
      #manage interface
      device.vm.network "private_network", :name => 'vboxnet0', :mac => "aaaaaaa11112", :adapter => 1, auto_config: false, ip: "172.16.5.12"

      #eth1
      device.vm.network "private_network", virtualbox__intnet: "15", auto_config: false , :mac => "aaaaaaaa0201"

      #eth2
      device.vm.network "private_network", virtualbox__intnet: "16", auto_config: false , :mac => "aaaaaaaa0202"


      device.vm.provider "virtualbox" do |vbox|
        vbox.customize ['modifyvm', :id, '--nicpromisc2', 'allow-all']
        vbox.customize ['modifyvm', :id, '--nicpromisc3', 'allow-all']
        vbox.customize ["modifyvm", :id, "--nictype1", "virtio"]
      end

      # Copy over configuration files

      device.vm.provision "file", source: "./config/dc2server/interfaces", destination: "~/interfaces"
      device.vm.provision "file", source: "./helper_scripts/dc2server.sh", destination: "~/dc2server.sh"
      device.vm.provision :shell , privileged: true, :inline => 'chmod +x /home/vagrant/dc2server.sh'
      
      device.vm.provision "file", source: "./config/dc2server/daemons", destination: "~/daemons"
      device.vm.provision :shell , privileged: true, :inline => 'cp /home/vagrant/daemons /etc/frr/daemons'
      
      device.vm.provision "file", source: "./config/dc2server/frr.conf", destination: "~/frr.conf"
      device.vm.provision :shell , privileged: true, :inline => 'cp /home/vagrant/frr.conf /etc/frr/frr.conf'

      device.vm.provision :shell , path: "./helper_scripts/config_server.sh"


      device.vm.provision :shell , privileged: true, :inline => 'echo dc2server > /etc/hostname'
      device.vm.provision :shell , privileged: true, :inline => 'echo 127.0.0.1    dc2server >> /etc/hosts'
      device.vm.provision :shell , privileged: true, :inline => 'rm -rf /etc/udev/rules.d/*'


       device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:02:01 --> eth1"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="aa:aa:aa:aa:02:01", NAME="eth1", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule
       device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:02:02 --> eth2"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="4aa:aa:aa:aa:02:02", NAME="eth2", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule



      device.vm.provision :shell , :inline => $script

  end


    ##### DEFINE VM for dc3server #####
    config.vm.define "dc3server" do |device|
      device.vm.box = "CumulusCommunity/cumulus-vx"
      device.vm.box_version = "3.7"
      device.vm.provider "virtualbox" do |v|
        v.name = "dc3server"
        v.memory = 512
      end

      device.vm.synced_folder ".", "/vagrant", disabled: true
        device.ssh.host = '172.16.5.13'


      # NETWORK INTERFACES
      # NETWORK INTERFACES
      #manage interface
      device.vm.network "private_network", :name => 'vboxnet0', :mac => "aaaaaaa11113", :adapter => 1, auto_config: false, ip: "172.16.5.13"
 
      #eth1
      device.vm.network "private_network", virtualbox__intnet: "17", auto_config: false , :mac => "aaaaaaaa0301"
      #eth2
      device.vm.network "private_network", virtualbox__intnet: "18", auto_config: false , :mac => "aaaaaaaa0302"


      device.vm.provider "virtualbox" do |vbox|
        vbox.customize ['modifyvm', :id, '--nicpromisc2', 'allow-all']
        vbox.customize ['modifyvm', :id, '--nicpromisc3', 'allow-all']
        vbox.customize ["modifyvm", :id, "--nictype1", "virtio"]
      end



      # Copy over configuration files

      device.vm.provision "file", source: "./config/dc3server/interfaces", destination: "~/interfaces"
      device.vm.provision "file", source: "./helper_scripts/dc3server.sh", destination: "~/dc3server.sh"
      device.vm.provision :shell , privileged: true, :inline => 'chmod +x /home/vagrant/dc3server.sh'
      device.vm.provision :shell , path: "./helper_scripts/config_server.sh"

      device.vm.provision :shell , privileged: true, :inline => 'echo dc3server > /etc/hostname'
      device.vm.provision :shell , privileged: true, :inline => 'echo 127.0.0.1    dc3server >> /etc/hosts'
      device.vm.provision :shell , privileged: true, :inline => 'rm -rf /etc/udev/rules.d/*'


       device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:03:01 --> eth1"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="aa:aa:aa:aa:03:01", NAME="eth1", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule
       device.vm.provision :shell , :inline => <<-udev_rule
  echo "  INFO: Adding UDEV Rule: aa:aa:aa:aa:03:02 --> eth2"
  echo 'ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="4aa:aa:aa:aa:03:02", NAME="eth2", SUBSYSTEMS=="pci"' >> /etc/udev/rules.d/70-persistent-net.rules
  udev_rule

      device.vm.provision :shell , :inline => $script

  end






#	##### DEFINE frr #####
#	config.vm.define "frr" do |device|
#	    device.vm.box = "centos/7"
#
#	    device.vm.provider "virtualbox" do |v|
#	      v.name = "frr"
#	      v.memory = 1024
#	    end
#
#	    device.vm.synced_folder ".", "/vagrant", disabled: true
#
#   
#	    device.vm.provider "virtualbox" do |vbox|
#	      vbox.customize ['modifyvm', :id, '--nicpromisc2', 'allow-all']
#	      vbox.customize ["modifyvm", :id, "--nictype1", "virtio"]
#	    end
#
#	    #host configuration
#	    device.vm.provision :shell , privileged: true, :inline => 'echo frr > /etc/hostname'
#	    device.vm.provision :shell , privileged: true, :inline => 'hostname frr'
#	    device.vm.provision :shell , privileged: true, :inline => 'echo 127.0.0.1  frr >> /etc/hosts'
#
#
#	    
#	    device.vm.provision :shell , privileged: true, :inline => 'yum install -y wget; wget https://github.com/FRRouting/frr/releases/download/frr-7.2/frr-7.2-01.el7.centos.x86_64.rpm; wget https://ci1.netdef.org/artifact/LIBYANG-YANGRELEASE/shared/build-10/CentOS-7-x86_64-Packages/libyang-0.16.111-0.x86_64.rpm; yum -y install libyang-0.16.111-0.x86_64.rpm; yum -y install frr-7.2-01.el7.centos.x86_64.rpm'
#	    device.vm.provision :shell , privileged: true, :inline => 'systemctl enable frr; systemctl start frr'
#
#	end


end

