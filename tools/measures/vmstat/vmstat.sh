#!/bin/sh

# shows the help with the command name in "$1"
usage() {
        echo "Usage: ${1##*/} [-d] [-h] [<duration>]"
        echo "   -d requests that each output line is timestamped (absolute)"
        echo "   -D requests that each output line is timestamped (relative)"
        echo "   -h shows this help"
        echo "  <duration> limits the number of seconds this task may run."
}

progname="$0"
timeout=""
timestamped=0

while [ -n "$1" -a -z "${1##-*}" ]; do
        if [ "$1" = "-h" ]; then
                usage "$progname"
                exit 0
        elif [ "$1" = "-d" ]; then
                timestamped=1
        elif [ "$1" = "-D" ]; then
                timestamped=2
        else
                usage "$progname"
                exit 1
        fi
        shift
done

if [ -n "$1" ]; then
        timeout=$1
        shift
fi

vmstat -n 1 | \
awk -v tout="$timeout" -v stmp="$timestamped" '
BEGIN{s = systime()}
{ t = systime()
  if (int(stmp) == 1)
      print t, $0
  else if (int(stmp) == 2)
      print t-s, $0
  else
      print $0
  fflush(stdout)
  if (tout != "" && t >= s+int(tout))
      exit
}'
