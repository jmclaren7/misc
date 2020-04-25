#!/bin/bash
# script to be used with proxmox as a vm hook script
# resets a VM after it has started in order to fix uefi screen resolution issue in macos
#echo parameters: $1 $2 [$0]

if [ $2 = "post-start" ]; then
  echo [post-start] start
  setsid /var/lib/vz/snippets/autoreset.sh $1 post-start-child &
  echo [post-start] end
elif [ $2 = "post-start-child" ]; then
  exec 0>&-
  exec 1>&-
  exec 2>&-
  sleep 6s
  echo reset $1
  qm reset $1

fi

exit 0