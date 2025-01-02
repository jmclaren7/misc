#!/bin/bash 
find /home/*/web/*/public_html/wp-admin/.. -maxdepth 0 -type d -exec bash -c 'echo $(echo "{}" | cut -d "/" -f3)' \; -exec bash -c 'sudo -u $(echo "{}" | cut -d "/" -f3) /usr/local/bin/wp --path={} '"$*" \;
