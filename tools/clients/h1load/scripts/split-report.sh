#!/bin/bash
# This script is used to split the large output from h1load into two files, one
# with the suffix "-load" containing the live load report output, and one with
# the suffix "-pctl" for the percentile output. It can process multiple files
# and will systematically produce the two output files, unless the part is
# missing from the input file(s).

# show usage with $1=command name and optional exit code in $2
usage() {
  echo "Usage: ${1##*/} [options]* h1load-report.rpt ..."
  echo "Will split each input file into two new ones with suffixes -load and -pctl".
  echo "Supported options:"
  echo "  -r        use a relative date starting at zero for the load report"
  echo "  -l <str>  use this suffix instead of '-load' for the load report"
  echo "  -p <str>  use this suffix instead of '-pctl' for the percentile report"
  echo "Input format must be the output of 'h1load -ll -P'."
  echo
  exit $2
}

set -e

loadsuf="-load"; pctlsuf="-pctl"; relative=""
while [ -n "$1" -a -z "${1##-*}" ]; do
  if [ "$1" = "-r" ]; then
    relative=1
    shift
  elif [ "$1" = "-l" ]; then
    loadsuf="$2"
    shift; shift
  elif [ "$1" = "-p" ]; then
    pctlsuf="$2"
    shift; shift
  elif [ "$1" = "-h" -o "$1" = "--help" ]; then
    usage "$0" 0
  else
    usage "$0" 1
  fi
done

if [ $# -eq 0 ]; then
  usage "$0" 1
fi

if [ -z "$loadsuf" -o -z "$pctlsuf" -o "$loadsuf" = "$pctlsuf" ]; then
  echo "The load and percentile suffixes may neither be identical nor empty."
  exit 1
fi

for file in "$@"; do
  if [ ! -s "$file" ]; then
    echo "Input file $file not existing or empty, ignoring."
    continue
  fi

  rm -f "${file}${loadsuf}"
  if [ -n "$relative" ]; then
    awk '/^#=/{exit;} /^[[:blank:]]*[[:digit:]]/{ if (t=="") t=int($1); $1-=t} /^#_/,/^#=/{print}' < "$file" > "${file}${loadsuf}"
  else
    sed -ne '/^#=/q;/^#_/,$p' < "$file" > "${file}${loadsuf}"
  fi

  if [ ! -s "${file}${loadsuf}" ]; then
    echo "Warning: input file ${file} produced an empty load report; forgot -ll ?"
    rm -f "${file}${loadsuf}"
  fi

  rm -f "${file}${pctlsuf}"
  sed -ne '/^#pct/,$p' "$@"  < "$file" > "${file}${pctlsuf}"
  if [ ! -s "${file}${pctlsuf}" ]; then
    echo "Warning: input file ${file} produced an empty percentile report; forgot -P ?"
    rm -f "${file}${pctlsuf}"
  fi
done
