#!/bin/bash
# info: rebuild all assets for all users
# options: [RESTART]
#
# example: v-rebuild-all-users
#
# This function rebuilds all assets for all users.

#----------------------------------------------------------#
#                Variables & Functions                     #
#----------------------------------------------------------#

# Argument definition
restart=$1

# Includes
# shellcheck source=/etc/hestiacp/hestia.conf
source /etc/hestiacp/hestia.conf
# shellcheck source=/usr/local/hestia/func/main.sh
source $HESTIA/func/main.sh
# shellcheck source=/usr/local/hestia/func/rebuild.sh
source $HESTIA/func/rebuild.sh
# shellcheck source=/usr/local/hestia/func/syshealth.sh
source $HESTIA/func/syshealth.sh
# load config file
source_conf "$HESTIA/conf/hestia.conf"

#----------------------------------------------------------#
#                    Verifications                         #
#----------------------------------------------------------#

# Perform verification if read-only mode is enabled
check_hestia_demo_mode

#----------------------------------------------------------#
#                       Action                             #
#----------------------------------------------------------#

# Rebuild loop
for user in $($BIN/v-list-sys-users plain); do
    $BIN/v-rebuild-all "$user" "$restart"
done

#----------------------------------------------------------#
#                       Hestia                             #
#----------------------------------------------------------#

# Logging
log_event "$OK" "$ARGUMENTS"

exit