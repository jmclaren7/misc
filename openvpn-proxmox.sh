wget https://git.io/vpn -O openvpn-install.sh && bash openvpn-install.sh




































#!/bin/bash

sudo apt -y update 
sudo apt -y upgrade

sudo apt -y install htop nano

sudo apt install openvpn easy-rsa

make-cadir ~/openvpn-ca
cd ~/openvpn-ca



export KEY_NAME="server"




wget http://prdownloads.sourceforge.net/webadmin/webmin_1.670_all.deb
dpkg --install webmin_1.670_all.deb

cd /usr/share/webmin
wget https://webmin-theme-stressfree.googlecode.com/files/theme-stressfree-2.10.tar.gz
tar -xzf theme-stressfree-2.10.tar.gz
cd ~

wget http://www.openit.it/downloads/OpenVPNadmin/openvpn-2.6.wbm.gz
gunzip openvpn-2.6.wbm.gz



rm -fv csf.tgz
wget http://www.configserver.com/free/csf.tgz
tar -xzf csf.tgz
sh csf/install.sh

echo 'iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT' > /etc/csf/csfpost.sh
echo 'iptables -A FORWARD -s 10.7.1.0/24 -j ACCEPT' >> /etc/csf/csfpost.sh
echo 'iptables -A FORWARD -j REJECT' >> /etc/csf/csfpost.sh
echo 'iptables -t nat -A POSTROUTING -s 10.7.1.0/24 -j SNAT --to-source 192.30.34.183' >> /etc/csf/csfpost.sh


# to check for tun/tap (bad state = enabled)
# cat /dev/net/tun

# disable unneeded services
# rcconf

push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"