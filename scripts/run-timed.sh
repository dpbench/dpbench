#!/bin/bash

# shows the help with the command name in "$1" and exits with code in $2
usage() {
        echo "Usage: ${1##*/} [-d] [-h] [-t timeout] <metric> <node> <test> -- <cmd> [args...]"
        echo "  -d requests that each output line is timestamped (absolute)"
        echo "  -D requests that each output line is timestamped (relative)"
        echo "  -h shows this help"
        echo "  -t <timeout> sets the maximum number of seconds this task may run."
        echo "  <metric> is among 'cli', 'cpu', 'mem', 'net'"
        echo "  <node> is a unique node name"
        echo "  <test> is the current test name or number, common with other nodes"
        echo "  <cmd> is the command to be started"
        echo
        exit $2
}

progname="$0"
timeout=""
timestamped=0

while [ -n "$1" -a -z "${1##-*}" ]; do
        if [ "$1" = "-h" ]; then
                usage "$progname" 0
        elif [ "$1" = "-d" ]; then
                timestamped=1
        elif [ "$1" = "-D" ]; then
                timestamped=2
        elif [ "$1" = "-t" ]; then
                timeout="$2"
                shift
        else
                usage "$progname" 1
        fi
        shift
done

if [ -z "$1" -o -z "$2" -o -z "$3" -o "$4" != "--" -o -z "$5" ]; then
        usage "$progname" 1
fi

metric="$1"; shift
node="$1"; shift
test="$1"; shift
shift; # "--"
# Now we have the command and args in "$@"

report_file="$metric-$node-$test.out"
cmd_file="$metric-$node-$test.cmd"
if [ -s "$report_file" ]; then
        echo "WARNING: output file $report_file already exists, press Enter to start anyway, ctrl-C to aboort."
        read
        echo "OK, overwriting the file."
fi

echo "Output will be sent to $report_file and the command to $cmd_file."

rm -f "$report_file" "$cmd_file"
echo "$*" > "$cmd_file"

echo "### Starting at $(date), redirecting to $report_file ###"

command "$@" | \
awk -v tout="$timeout" -v stmp="$timestamped" '
BEGIN{s = systime()}
{ t = systime()
  if (tout != "" && t > s+int(tout))
      exit
  if (int(stmp) == 1)
      print t, $0
  else if (int(stmp) == 2)
      print t-s, $0
  else
      print $0
  fflush(stdout)
}'| tee "$report_file"
