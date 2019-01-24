#!/bin/bash
cat >/etc/rc.d/init.d/openvpn-tun <<EOL
if ! [ -c /dev/net/tun ]; then
mkdir -p /dev/net
mknod /dev/net/tun c 10 200
ip tuntap add mode tap
systemctl restart openvpn@server.service
fi
EOL
chmod +x /etc/rc.d/init.d/openvpn-tun

curl -O https://raw.githubusercontent.com/Angristan/openvpn-install/master/openvpn-install.sh
bash openvpn-install.sh