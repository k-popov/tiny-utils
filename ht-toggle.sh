#!/bin/sh

syscpu='/sys/devices/system/cpu'

# list CPU IDs
cpu_list() {
    cat /proc/cpuinfo | awk '($1 == "processor" && $2 = ":") {print $3}'
}

all_cores() {
# lists all CPUs (both physical and HT virtuals)
    cd "$syscpu" && ls cpu* | tr -d -c '[0-9\n]'
}

# if CPU is offline or the flag is unknown
online_is_nul() {
    test "$(cat "$syscpu"'/cpu'"$1"'/online' 2>/dev/null)" = "0"
}

# if CPU is online and the flag exists
online_is_one() {
    test "$(cat "$syscpu"'/cpu'"$1"'/online' 2>/dev/null)" = "1"
}

# turn CPU off
turnoff() {
    echo "0" > "$syscpu"'/cpu'"$1"'/online'
}

# turn CPU on
turnon() {
    echo "1" > "$syscpu"'/cpu'"$1"'/online'
}

# CPU siblings mask
siblings() {
    cat "$syscpu"'/cpu'"$1"'/topology/thread_siblings'
}

if test "$1" = "on"; then
    for id in $(all_cores) ; do
        turnon "$id" 2>/dev/null && echo "CPU $id is online now"
    done
elif test "$1" = "off"; then
    # list siblings of all online CPUs
    for id in $(cpu_list) ; do
        # omit offline CPUs
        online_is_nul "$id" && continue
        siblings "$id"
    done \
        | sort \
        | uniq -d \
        | while read sibling ; do
            # find the highest CPU ID with the given sibling
            for id in $(cpu_list | sort -nr) ; do
                online_is_one "$id" || continue
                test "$(siblings "$id")" = "$sibling" || continue
                turnoff "$id"
                echo "$id" turned off
                break # only one HT core may exists
            done
        done
else
    echo "Usage: $0 <on|off>"
fi
