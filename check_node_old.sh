#!/bin/bash

check_node() {
local ID="$1"
local NODE="$2"
local INFOLINE="$3"
UPTIME_LINE="$(ssh -q -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null $NODE uptime < /dev/null)"
if echo "${UPTIME_LINE}" | grep -q 'days'; then
    echo "${ID}:${NODE}:OLDERTHANADAY"
    return 0
fi

TIME="`echo ${UPTIME_LINE} | grep -o -E '[0-9]{1,2}:[0-9]{1,2},' | tr -d ','`"
H="`echo ${TIME} | cut -f 1 -d :`"
M="`echo ${TIME} | cut -f 2 -d : | sed -e 's/^0*//'`" # cut 0 if it's frst in minutes value
test -z "$H" && H="0"
test -z "$M" && M="0"

MIN_TOTAL=$(( 10#$H * 60 + 10#$M ))

echo "${ID}:${NODE}:${MIN_TOTAL}:${INFOLINE}"
return 0
}

#lc-node-list | grep -E 'CI\.[A-Z0-9]{8}-[0-9]{3}\.[A-Z0-9]' \
lc-node-list -f "%(id)s	%(name)s	%(ip)s	%(password)s	%(ram)s	%(description)s" \
    | grep -E 'CI\.[A-Z0-9]{8}-[0-9]{3}\.[A-Z0-9]' \
    | while read GG_LINE; do
        ID="`echo \"${GG_LINE}\" | cut -f 1`"
        NAME="`echo \"${GG_LINE}\" | cut -f 2`"
        IP="`echo \"${GG_LINE}\" | cut -f 3`"
        # 4-th is password
        RAM="`echo \"${GG_LINE}\" | cut -f 5`"
        DESCR="`echo \"${GG_LINE}\" | cut -f 6-`"
        [[ "$ID" = "None" ]] && continue

        check_node "${ID}" "${IP}" "${NAME}:${RAM}:${DESCR}"

    done

exit 0
