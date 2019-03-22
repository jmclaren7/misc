#!/bin/bash
PATH=$PATH:/usr/local/bin
LOGFILE=/var/log/nextcloudbackup.log
savelog -n -l -c 5 LOGFILE

exec >> $LOGFILE
exec 2>&1

EMAIL=email@domain.tld
echo " "
date
echo " "

mysqldump --databases nextcloud > /var/nextcloud-data/nextcloud-dump.sql
cp -a /var/www/nextcloud/config /var/nextcloud-data/config-backup

# Setup command
RUNCMD="aws s3 sync /var/nextcloud-data/ s3://jcs-webservers/s2.johnscs.link/nextcloud-data/ --delete"

# Execute command
echo $RUNCMD
eval "$RUNCMD" 
error=$?

echo "Command complete"

##Sent email alert
subj="Backup Notification From `hostname`"

msg="COMMAND: " $RUNCMD 

if [ $error -eq 0 ];then
subj="Nexcloud Backup Successful"
msg="$SOURCE $msg Amazon s3 Backup Uploaded Successfully"
else
subj="Nextcloud Backup Failed"
msg="$SOURCE $msg Amazon s3 Backup Failed!! Check ${LOGFILE} for more details. Error: $error" 
fi
echo -e "$msg"|mail -r email@hostname.tld -s "$subj" ${EMAIL}
echo $msg