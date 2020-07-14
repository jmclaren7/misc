yum update
yum install epel-release
yum install wget htop mlocate

wget https://www.screenconnect.com/Download?Action=DownloadLatest&Platform=Linux&PreRelease=false
tar -xzf ScreenConnect_*.tar.gz
chmod +x sc-install.sh 
./sc-install.sh 
systemctl enable screenconnect
systemctl start screenconnect

yum install nginx certbot-nginx
nano /etc/nginx/conf.d/default.conf
certbot --nginx -d sc.resolvetech.biz
mkdir /etc/nginx/ssl
openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048
systemctl enable nginx
systemctl start nginx
