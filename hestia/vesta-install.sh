#============ Remi ============
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
wget http://rpms.remirepo.net/enterprise/remi-release-7.rpm
rpm -Uvh remi-release-7.rpm epel-release-latest-7.noarch.rpm

#============ Basic ============
yum -y remove httpd bind-9 httpd-tools
yum -y upgrade
yum -y install epel-release htop nano yum-cron yum-utils
mv -f /etc/localtime /etc/localtime.bak
ln -s /usr/share/zoneinfo/America/New_York /etc/localtime

#============ Automatic System Updates ============
sed -i 's/apply_updates = no/apply_updates = yes/g' /etc/yum/yum-cron.conf
sed -i 's/update_cmd = default/update_cmd = security/g' /etc/yum/yum-cron.conf
systemctl enable yum-cron
systemctl start yum-cron
systemctl status yum-cron

#============ VESTA ============
curl -O http://vestacp.com/pub/vst-install.sh
bash vst-install.sh --interactive no --nginx yes --phpfpm no --apache yes --proftpd yes --quota no --spamassassin no --clamav no --hostname `hostname -f` --email admin+`hostname`@johnscs.com --password qT1XvdW4wC6p 
yum -y upgrade

# Reboot due to env issues?
# iptables and named running after reboot?

/usr/local/vesta/bin/v-delete-user-package gainsboro
/usr/local/vesta/bin/v-delete-user-package palegreen
/usr/local/vesta/bin/v-delete-user-package slategrey
sed -i "s/NS='ns1.localhost.ltd,ns2.localhost.ltd'/NS='ns1.`hostname -f`,ns2.`hostname -f`'/g" /usr/local/vesta/data/packages/default.pkg
sed -i "s/NS='ns1.domain.tld,ns2.domain.tld'/NS='ns1.`hostname -f`,ns2.`hostname -f`'/g" /usr/local/vesta/data/packages/default.pkg
sed -i "s/BACKUPS='3'/BACKUPS='7'/g" /usr/local/vesta/data/packages/default.pkg
/usr/local/vesta/bin/v-update-web-templates
/usr/local/vesta/bin/v-update-user-package default


#============ SSL GUI ============
v-add-letsencrypt-domain admin `hostname -f`

rm -f /usr/local/vesta/ssl/certificate.*
ln -s /home/admin/conf/web/ssl.`hostname -f`.pem /usr/local/vesta/ssl/certificate.crt
ln -s /home/admin/conf/web/ssl.`hostname -f`.key /usr/local/vesta/ssl/certificate.key
chown root:mail /usr/local/vesta/ssl/certificate.*
crontab -l | { cat; echo "15 6 * * * chown root:mail /usr/local/vesta/ssl/certificate.*"; } | crontab -
crontab -l | { cat; echo "15 6 * * * systemctl restart vesta"; } | crontab -
systemctl restart vesta

#============ NGINX ============
touch /usr/local/vesta/data/templates/web/skel/public_html/nginx.conf

cp /usr/local/vesta/data/templates/web/nginx/php-fpm/default.stpl /usr/local/vesta/data/templates/web/nginx/php-fpm/default-include.stpl
cp /usr/local/vesta/data/templates/web/nginx/php-fpm/default.tpl /usr/local/vesta/data/templates/web/nginx/php-fpm/default-include.tpl

# add to bottom of new files: include     %home%/%user%/web/%domain%/public_html/nginx.conf;

#============ PHP 7 ============
service php-fpm stop
yum-config-manager --disable remi-php55
yum-config-manager --disable remi-php56
yum-config-manager --enable remi-php72

yum -y update

chkconfig php-fpm on

sed -i 's/pm = dynamic/pm = ondemand\npm.process_idle_timeout = 20s\npm.max_requests = 500/g' /usr/local/vesta/data/templates/web/php-fpm/default.tpl
# Will need to rebuild domains if they already exist

#============ phpMyAdmin ============
# If repo install doesnt work due to php7 not meeting dependencies
#cd /usr/share
#wget https://files.phpmyadmin.net/phpMyAdmin/4.7.1/phpMyAdmin-4.7.1-all-languages.zip
#unzip phpMyAdmin-*-all-languages.zip
#rm phpMyAdmin-*-all-languages.zip
#mv phpMyAdmin-*-all-languages phpMyAdmin
#chmod -R 0755 phpMyAdmin

# change nginx alias and vestacp link
# nginx virtual host config has locations the name needs to be changed
sed -i 's/phpmyadmin/jcsphpmyadmin/g' /etc/nginx/conf.d/phpmyadmin.inc
sed -i 's#Alias /php#Alias /jcsphp#g' /etc/httpd/conf.d/phpMyAdmin.conf
sed -i 's/phpmyadmin/jcsphpmyadmin/g' /usr/local/vesta/web/templates/admin/list_db.html
systemctl restart nginx

#============ Fail2Ban ===============

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

#============ FUSE ============
yum -y install gcc libstdc++-devel gcc-c++ curl-devel libxml2-devel openssl-devel mailcap

cd /usr/src/
wget https://github.com/libfuse/libfuse/releases/download/fuse-3.0.2/fuse-3.0.2.tar.gz
tar xzf fuse-3.0.2.tar.gz
cd fuse-3.0.2
./configure --prefix=/usr/local
make && make install
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
ldconfig
modprobe fuse

#============ FUSE-AWS ============
yum -y install automake fuse fuse-devel gcc-c++ git libcurl-devel libxml2-devel make openssl-devel

git clone https://github.com/s3fs-fuse/s3fs-fuse.git
cd s3fs-fuse
./autogen.sh
./configure
make && make install

echo MYIDENTITY:MYCREDENTIAL > /etc/passwd-s3fs
chmod 600 /etc/passwd-s3fs

mkdir /s3backup
echo "jcs-webservers:/s3.johnscs.link /s3backup/vesta fuse.s3fs _netdev,allow_other 0 0" >> /etc/fstab
mount -a
mkdir /s3backup/vestacp
ln -s /s3backup/vestacp /backup


# Edit fstab to FUSE.s3 mount on /s3backup and change vesta settings
# nano /etc/fstab
# jcs-webservers:/s8.johnscs.link /s3backup fuse.s3fs _netdev,allow_other 0 0

#============ MariaDB 10 ============
# nano /etc/yum.repos.d/MariaDB10.repo
printf "[mariadb]\nname = MariaDB\nbaseurl = http://yum.mariadb.org/10.2/centos7-amd64\ngpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB\ngpgcheck=1\n" > /etc/yum.repos.d/MariaDB10.repo

systemctl stop mariadb
yum -y update
systemctl start mariadb
mysql_upgrade


#============ Post Install ============
# Change name server in server settings and in package setting
# Change nginx template under packages

# Rebuild all domains or execute command across all users
cd /home && v-rebuild-web-domains admin && find * -maxdepth 0 -path admin -prune -o -path backup -prune -o -type d -exec echo {} \; -exec v-rebuild-web-domains {} \;
sed -i 's/168.235.80.210/168.235.108.179/g' /usr/local/vesta/data/users/*/dns/*.conf
sed -i 's/s5.johnscs.link/s3.johnscs.link/g' /usr/local/vesta/data/users/*/dns/*.conf
cd /home && find * -maxdepth 0 -path backup -prune -o -type d -exec echo {} \; -exec v-change-user-ns {} ns1.s3.johnscs.link ns2.s3.johnscs.link \;
cd /home && find * -maxdepth 0 -path backup -prune -o -type d -exec echo {} \; -exec v-rebuild-dns-domains {} \;


cd /home && find * -maxdepth 0 -path admin -prune -o -path backup -prune -o -type d -exec echo {} \; -exec /root/v-fix-user.sh {} \;











