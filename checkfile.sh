#!/bin/bash
FILE="$1"
[ $# -eq 0 ] && exit 1
dt=$(date '+%d/%m/%Y %H:%M:%S')
if [[ -r "$FILE" && -w "$FILE" ]]; then
    echo "$dt We can read and write the $FILE"
else
    echo "$dt Access denied, killing container"
    /sbin/killall5
fi
