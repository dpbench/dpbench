#!/bin/bash

# This script will read two load output files from h1load and produce a graph
# showing the response time distribution long a percentile axis.
# The default output will be a PNG file under the same name but with the
# extension replaced with ".png".
#

# show usage with $1=command name and optional exit code in $2
usage() {
  echo "Usage: ${1##*/} [-h|--help] [-t title] [-l] [-o outfile] <pctfile> [<pctfile>]"
  echo "   -h --help      display this help"
  echo "   -l             use a log scale on y (increases the dynamic range)"
  echo "   -o outfile     output PNG file (default: same as pctfile with .png)"
  echo "   -t title       set the graph's title"
  echo "   pctfile        h1load percentile output from the main worker. A second file"
  echo "                  name may be specified. Their labels may be set after a ':'"
  echo "                  placed after their name"
  echo
  echo "If no title is set, the name of the files will be used."
  exit $2
}


out=""; log=""
while [ -n "$1" -a -z "${1##-*}" ]; do
  if [ "$1" = "-t" ]; then
    title="$2"
    shift; shift
  elif [ "$1" = "-l" ]; then
    log=1
    shift;
  elif [ "$1" = "-o" ]; then
    out="$2"
    shift; shift
  elif [ "$1" = "-r" ]; then
    ref="$2"
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

pct1="$1"; desc1="${pct1}"
if [ -n "$desc1" -a -z "${desc1##*:*}" ]; then
  desc1="${desc1#*:}"
  pct1="${pct1%:$desc1}"
else
  desc1="${desc1##*/}"
  desc1="${desc1%.*}"
fi

pct2="$2"; desc2="${pct2}"
if [ -n "$desc2" -a -z "${desc2##*:*}" ]; then
  desc2="${desc2#*:}"
  pct2="${pct2%:$desc2}"
else
  desc2="${desc2##*/}"
  desc2="${desc2%.*}"
fi

if [ -z "$out" ]; then
  out=${pct1%.*}.png
fi

if [ -z "$title" ]; then
  if [ -z "$pct2" ]; then
    title="${desc1} latency (ms)"
  else
    title="${desc1} vs ${desc2} latency (ms)"
  fi
fi

gnuplot << EOF
  stats '$pct1' using 3:5 nooutput; pct1max=STATS_max_y
  ${pct2:+stats '$pct2' using 3:5 nooutput; pct2max=STATS_max_y}

  set title "$title"
  set grid lt 0 lw 1 ls 1 lc rgb "#d0d0d0"
  ${log:+set logscale y2}
  set yrange [0:1]
  unset ytics
  set y2range [0:]
  set y2tics nomirror
  set xtics nomirror border
  set grid y2
  set xlabel "Percentile" #offset 0,0.5
  set y2label "Latency (milliseconds)"
  #set key inside bottom center box
  #set key outside bottom center horizontal spacing 1.5 reverse Left width +2
  set key inside top left vertical spacing 1.0 reverse Left width +2
  #set terminal png font courbi 9 size 800,400
  set terminal pngcairo size 800,400 background rgb "#f0f0f0"
  set style fill transparent solid 0.3 noborder
  set output "${out%.*}.png"
  set logscale x 10
  set xrange [1:1000000]
  set xtics ("0%%" 1, "|\nmean (50%%)" 2, "90%%" 10, "99%%" 100, "99.9%%" 1000, "99.99%%" 10000, "99.999%%" 100000, "99.9999%%" 1000000)
  set format y2 "%.1f"

  plot \
            '$pct1' using 3:5 with lines title sprintf('%s (max=%.3f)','$desc1',pct1max) lt 1 lw 3 axis x1y2, \
    ${pct2:+'$pct2' using 3:5 with lines title sprintf('%s (max=%.3f)','$desc2',pct2max) lt 2 lw 3 axis x1y2,} \
            '$pct1' using 3:5 with filledcurves x1 notitle lt 1 axis x1y2           \
   ${pct2:+,'$pct2' using 3:5 with filledcurves x1 notitle lt 2 axis x1y2}

EOF
