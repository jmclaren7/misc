yum update
yum install epel-release
yum install wget htop mlocate

wget https://d1kuyuqowve5id.cloudfront.net/ScreenConnect_19.0.23665.7058_Release.tar.gz
tar -xzf ScreenConnect_19.0.23665.7058_Release.tar.gz
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
