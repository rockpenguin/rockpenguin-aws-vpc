#!/bin/bash
sudo yum install iptables-services -y
sudo systemctl enable iptables
sudo systemctl start iptables
sudo echo "net.ipv4.ip_forward=1" | sudo /bin/tee /etc/sysctl.d/nat-ip-forwarding.conf
sudo sysctl -p /etc/sysctl.d/nat-ip-forwarding.conf
sudo /sbin/iptables -t nat -F
sudo /sbin/iptables -t nat -A POSTROUTING -s ${vpc_cidr} -j MASQUERADE
sudo /sbin/iptables -F FORWARD
sudo service iptables save
