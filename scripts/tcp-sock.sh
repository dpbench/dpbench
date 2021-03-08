#!/bin/bash

# reports TCP sockets in-use, orphans and timewaits every second
echo "#inuse orphans timewait"
while sleep 1; do
        while read a b c d e f g h; do
                [ "$a" != "TCP:" ] || break
        done </proc/net/sockstat
        if [ "$a" = "TCP:" ]; then
                echo "$c $e $g"
        fi
done
