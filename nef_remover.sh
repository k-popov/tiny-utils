#!/bin/bash

RDY_DIR="rdy"
declare -a REMOVE
declare -a LEAVE

for NEF in $(find . -iname "*.NEF"); do
    NEF="$(basename $NEF)"
    NAME="$(echo $NEF | cut -f 1 -d .)"
    JPGS_NUM=$(find $RDY_DIR -iname "$NAME.*" | wc -l)
    if test $JPGS_NUM -eq 0; then
        REMOVE+=("${NEF}")
    else
        LEAVE+=("${NEF}")
    fi
done

echo "Going to leave $(echo ${LEAVE[@]} | wc -w) *.NEF files. OK (yes/no)?"
read ANSWER
if [[ "$ANSWER" == "yes" ]]; then
    for NEF in ${REMOVE[@]}; do
        rm -v $NEF
    done
fi
