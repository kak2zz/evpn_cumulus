#!/bin/bash

echo "#################################"
echo "  Running MANAGE server config"
echo "#################################"
sudo su

#echo " ### Updating APT Repository... ###"
#apt-get update -y

#echo " ### Installing Packages... ###"
#apt-get install -y htop isc-dhcp-server tree apache2 vlan git python-pip dnsmasq ifenslave apt-cacher-ng sshpass lldpd
#echo " ### Installing ansible... ###"
#apt-get install -y build-essential libssl-dev libffi-dev python-dev
#pip install pip --upgrade
#pip install setuptools --upgrade
#pip install ansible --upgrade

#echo " ### Moving Ansible Hostfile into place ###"
#mkdir -p /etc/ansible
#mv /home/vagrant/ansible_hostfile /etc/ansible/hosts


echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC3wPLkNPzh5m33xCuNhLcNMTdRWN0tYYmVCKkBKVDk5LHqhnmA1LRNCvrL7LL/YWPV0vyrkJM+5frRPdptQAyOr5CM6cma+I7QevFcjrffx7EEyvMJKKKYX1l2v+7A61nvznhPoFCgJGG2iqEeJQEFB8WbR30BljtaBgJZRgFwiQ/p8bzrL7PoydDke0D3bDDOKrlz4YVia0LIO3JwB0Hzq5kuQpgS4rP0Emxh01KadCttxSr+9RVUs3ff77gz8h7ojurC966OsxbUb8b+HaUTmHnBG2Op4oyL+sXu4BADh7bO9yNU6GPmAMACxxyGuHenBfEd9Ff//49g6Kv875AX eenin-0" >> /home/vagrant/.ssh/authorized_keys
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDAteg6u3RNvJ4oQiTgtPGmeNV85nup/u3IHjhgqVmEe5av7M5ISK5nfDqJqoCQSNroeZ6j36G9xuhgWBketK0PLwzlOgek6PireKROLlmCZDXRv6oCGC+SrpCPP3u80Z8c3/ErnesAUxs1PeftIhVZ0/+pxcEtjBWNZA3Eh0KBoLDwTwXnv4yysQCD6C8LZfUbrUJJJcOOaRFIGRIortElbtuZvkaq/gucke9sCquKOBGxoi5BksePSQFoIQfZEF6bNPraTv4GIsOXAT2OLNnx2li/4s1LN1pKsQI/eL1JeeLMex7KlT06YleE1IBcu1z+isF0q5u0S9VygrWlFrN/L997wh15NRRTYKQziZwVftVjfPaaYHRlJypCzf2sHL/RZkodlnMoxGKNkfuV2yVsF8RZeKTmOpfimUJ5/ayf1H6bgUqoFG8flyfdqHN9FVkv8yxjvdSH3aDuJiwXfIRN+7iEqiOujvnBI0wKgX4nsEC4/mOejjq8jX1ubXEv2YVpoyoohgqwcqUaiW1vO3mRZsu0aixzTinFi2SHwVUVA7YplkLjHILN9UvYDoo2P87SP1PYMp3cYFanIfnqUK4IaA1hWhOpgxrDeTWzWXnkE89uKTAh7mCVw94IlJTF0lKgqhTos9AUFfkPHSQM/J8dbzpdJbYcBqrguYijVw2tWQ== msizov-0" >> /home/vagrant/.ssh/authorized_keys

echo "#################################"
echo "   Finished"
echo "#################################"
