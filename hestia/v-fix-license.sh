#!/bin/bash
PATH="$PATH:/usr/local/sbin:/sbin:/usr/sbin:/root/bin"
sed -c -i "s/\(FILEMANAGER_KEY *= *\).*/\1"3"/" /usr/local/vesta/conf/vesta.conf
