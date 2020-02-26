#!/bin/bash

echo "#################################"
echo "  Configure.."
echo "#################################"

ip link add link bond0 bond0.100 type vlan proto 802.1ad id 100
ip link add link bond0.100 bond0.100.20 type vlan proto 802.1Q id 20
ip link set bond0 up
ip link set bond0.100 up
ifconfig bond0.100.20 10.100.20.1/24

ip link add link bond0 bond0.200 type vlan proto 802.1Q id 200
ip link set bond0.200 up
ifconfig bond0.200 10.200.0.1/24


echo "#################################"
echo "   Finished"
echo "#################################"
