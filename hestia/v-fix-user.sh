#!/bin/bash

USER=$3
OLDIP=$1
OLDHOST=$2

if [ ! -z $2 ]
then
echo "Updating DNS IPs"
sed -i "s/$OLDIP/`hostname -i`/g" /usr/local/hestia/data/users/$USER/dns/*.conf
fi

if [ ! -z $3 ] 
then
echo "Updating DNS Host Names"
sed -i "s/$OLDHOST/`hostname -f`/g" /usr/local/hestia/data/users/$USER/dns/*.conf
fi

echo "Updating SOAs"
for fullfile in /home/$USER/conf/dns/*.db; do
    filename=$(basename -- "$fullfile")
    DOMAIN="${filename%.*}"
    v-change-dns-domain-soa $USER $DOMAIN ns1.`hostname -f`
done

echo "Updating Web Template"
for fullfile in /home/$USER/web/*; do
    WEB=$(basename -- "$fullfile")
    v-change-web-domain-tpl $USER $WEB default
done

echo "Updating Name Servers"
v-change-user-ns $USER ns1.`hostname -f` ns2.`hostname -f`

echo "Rebuild DNS"
v-rebuild-dns-domains $USER

echo "Rebuild Web"
v-rebuild-web-domains $USER
