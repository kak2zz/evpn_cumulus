#!/bin/bash

echo "#################################"
echo "  Configure namespaces.."
echo "#################################"

#internet test client 1
ip netns add internet_client_1
vconfig add bond0 10
ip link set dev bond0.10 netns internet_client_1
ip netns exec internet_client_1 ip link set bond0.10 address 02:ac:10:ff:00:11
ip netns exec internet_client_1 ip link set bond0.10 up
ip netns exec internet_client_1 ip link set bond0.10 mtu 1500
ip netns exec internet_client_1 ip addr add 10.0.0.10/24 dev bond0.10
ip netns exec internet_client_1 ip ro add 0.0.0.0/0 via 10.0.0.1


#internet test client 2
ip netns add internet_client_2
vconfig add bond0 20
ip link set dev bond0.20 netns internet_client_2
ip netns exec internet_client_2 ip link set bond0.20 address 02:ac:10:ff:00:12
ip netns exec internet_client_2 ip link set bond0.20 up
ip netns exec internet_client_2 ip link set bond0.20 mtu 1500
ip netns exec internet_client_2 ip addr add 10.0.0.20/24 dev bond0.20
ip netns exec internet_client_2 ip ro add 0.0.0.0/0 via 10.0.0.1


#vlan test over vxlan with vlan-aware bridge
ip netns add vlan_test
vconfig add bond0 100
ip link set dev bond0.100 netns vlan_test
ip netns exec vlan_test ip link set bond0.100 address 02:ac:10:ff:00:13
ip netns exec vlan_test ip link set bond0.100 up
ip netns exec vlan_test ip link set bond0.100 mtu 1500
ip netns exec vlan_test ip addr add 10.0.100.1/24 dev bond0.100

#QinQ test over vxlan with linux bridge
ip netns add qinq_test_1000_10
ip netns add qinq_test_1000_20
vconfig add bond0 1000
ip link set up bond0.1000 
vconfig add bond0.1000 10
vconfig add bond0.1000 20
ip link set dev bond0.1000.10 netns qinq_test_1000_10
ip link set dev bond0.1000.20 netns qinq_test_1000_20
ip netns exec qinq_test_1000_10 ip link set bond0.1000.10 address 02:ac:10:ff:00:14
ip netns exec qinq_test_1000_20 ip link set bond0.1000.20 address 02:ac:10:ff:00:15
ip netns exec qinq_test_1000_10 ip link set bond0.1000.10 up
ip netns exec qinq_test_1000_20 ip link set bond0.1000.20 up
ip netns exec qinq_test_1000_10 ip link set bond0.1000.10 mtu 1500
ip netns exec qinq_test_1000_20 ip link set bond0.1000.20 mtu 1500
ip netns exec qinq_test_1000_10 ip addr add 10.100.10.1/24 dev bond0.1000.10
ip netns exec qinq_test_1000_20 ip addr add 10.100.20.1/24 dev bond0.1000.20




echo "#################################"
echo "   Finished"
echo "#################################"
