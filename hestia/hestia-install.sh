#============ Basic ============
apt update
apt dist-upgrade
apt install -y htop nano
timedatectl set-timezone America/New_York

#============ Swap =============
fallocate -l 512M /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Set swappiness and pressure 
sysctl vm.swappiness=10
echo "vm.swappiness=10" >> /etc/sysctl.conf

sysctl vm.vfs_cache_pressure=50
echo "vm.vfs_cache_pressure=70" >> /etc/sysctl.conf

#============ Automatic System Updates ============
apt install unattended-upgrades
nano /etc/apt/apt.conf.d/50unattended-upgrades
nano /etc/apt/apt.conf.d/20auto-upgrades

#============ Hestia ============
groupdel admin
apt -y remove ufw*

wget https://raw.githubusercontent.com/hestiacp/hestiacp/release/install/hst-install.sh
bash hst-install.sh -r 8093 --clamav no --spamassassin no --email admin@mydomain.com

#============ SSL GUI ============
v-add-letsencrypt-host

#============ NGINX ==============

#============ PHP ================

#============ phpMyAdmin =========

#============ Fail2Ban ===========

# Jail rules for /etc/fail2ban/jail.local
#[wordpresshard-iptables]
#enabled = true
#filter = wordpress-hard
#action  = vesta[name=WEB]
#logpath = /var/log/messages
#maxretry = 2
#
#[wordpresssoft-iptables]
#enabled = true
#filter = wordpress-soft
#action  = vesta[name=WEB]
#logpath = /var/log/messages
#maxretry = 4

# Filters can be found in the wordpress fail2ban redux plugin

#============ FUSE ===============
apt install s3fs
nano .passwd-s3fs
chmod 600 .passwd-s3fs


mkdir /backup
echo "bucket:/folder/vestacp /backup fuse.s3fs _netdev,allow_other 0 0" >> /etc/fstab
mount -a

#============ MariaDB == =========

#============ Post Install ============
